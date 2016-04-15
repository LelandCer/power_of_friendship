require 'squeel'

module PowerOfFriendship


  module ActsAsFriend
    extend ActiveSupport::Concern

    included do

    end

    module ClassMethods
      def act_as_friend(options = {})

        def self.pow_name_und
          self.name.underscore.downcase
        end

        def self.pow_friendship_model
          "#{self.name}Friendship".constantize
        end

        def self.pow_friendship_table
          "#{pow_name_und}_friendships"
        end

        def self.pow_model_id
          "#{pow_name_und}_id".to_sym

        end

        has_many :friends, 
        through: :approved_friendships,
        :source => :friend

        has_many :approved_friendships,
        ->(t) {where("#{t.pow_friendship_table}.pending" => false)},
        :foreign_key => pow_model_id,
        :class_name => pow_friendship_model


        has_many  :friendships,
        foreign_key: pow_model_id,
        class_name: pow_friendship_model,
        dependent: :destroy

        has_many  :followers,
        :through => :inverse_friendships,
        source: pow_name_und

        has_many  :invited_friends,
        :through => :invited_friendships,
        source: :friend

        has_many :invited_friendships,
        ->(t) {where("#{t.pow_friendship_table}.pending" => true)},
        :foreign_key => pow_model_id,
        :class_name => pow_friendship_model


        has_many  :inverse_friendships,
        :class_name => pow_friendship_model,
        :foreign_key => :friend_id,
        dependent: :destroy

        has_many  :inverse_followers,
        :through => :friendships,
        source: :friend

        has_many  :pending_friends,
        ->(t) {where("#{t.pow_friendship_table}.pending" => true)},
        :through => :pending_friendships,
        source: pow_name_und

        has_many :pending_friendships,
        ->(t) {where("#{t.pow_friendship_table}.pending" => true)},
        :foreign_key => :friend_id,
        :class_name => pow_friendship_model


        include PowerOfFriendship::ActsAsFriend::LocalInstanceMethods
      end
    end

    module LocalInstanceMethods
      def pow_name_und
        self.class.pow_name_und
      end

      def pow_model_id
        self.class.pow_model_id
      end

      def pow_friendship_model
        self.class.pow_friendship_model
      end

      def pow_friendship_table
        self.class.pow_friendship_table
      end



      def invite(friend)
        return false if friend == self || find_any_friendship_with(friend)
        friendship = pow_friendship_model.new( pow_model_id => self.id, :friend_id => friend.id, pending: true ).save
        friendship
      end  

      def approve(friend)
        friendship = pow_friendship_model.where(pow_model_id => friend.id, :friend_id => self.id, pending: true).first
        return false if friendship.nil?
        if friendship.update_attribute(:pending, false)
          create_complimentary_friendship friendship  
          true    
        else
          false 
        end 
      end

      def unfriend(friend)
        friendship = self.find_any_friendship_with friend
        return true if not friendship
        friendship.destroy
        self.destroy_complimentary_friendship friendship
      end

      def follow(model)
        return true if self.invite(model)
        return self.approve model
      end

      def unfollow(model)
        followership = pow_friendship_model.where(pow_model_id => self.id, :friend_id => model.id).first
        return true if not followership
        followership.destroy

        if followership.approved?
          other_followership = find_friendship_complement followership
          other_followership.pending = true
          other_followership.save
        end
        return true
      end

      def friends_with?(model)
        self.friends.include?(model)
      end

      def follows?(model)
        self.inverse_followers.include?(model)
      end

      def followed_by?(model)
        self.followers.include?(model)
      end

      def connected_with?(model)
        find_any_friendship_with(model).present?
      end

      def invited_by?(model)
        friendship = find_any_friendship_with(model)
        return false if friendship.nil?
        return friendship.send(pow_model_id) == model.id if friendship.pending == true
        inverse_friendship = find_friendship_complement friendship
        return friendship.send(pow_model_id) == model.id if friendship.created_at <= inverse_friendship.created_at
        return inverse_friendship.send(pow_model_id) == model.id 
      end

      def invited?(model)
        friendship = pow_friendship_model.where(pow_model_id => self.id, :friend_id => model.id).first
        return false if friendship.nil?
        return friendship.friend_id == model.id if friendship.pending == true
        inverse_friendship = find_friendship_complement friendship
        return friendship.friend_id == model.id if friendship.created_at <= inverse_friendship.created_at
        return inverse_friendship.friend_id == model.id 
      end

      def suggested_friends
        pow_model_id_column = pow_model_id # TODO figure out how to avoid this
        table = pow_friendship_table # TODO figure out how to avoid this
        self_table = "#{pow_name_und}s"

        approved_friendships = pow_friendship_model.where{
          (  __send__(pow_model_id_column) == my{id}) & 
          ( pending       == false  ) 
        }

        pending_friendships = pow_friendship_model.where{
          ( (  __send__(pow_model_id_column) == my{id}) |
            ( friend_id == my{id}) ) &
          ( pending      == true  ) 
        }

        buddies_relations = pow_friendship_model.where{
          (  __send__(pow_model_id_column).in(approved_friendships.select{friend_id} ) ) & 
          (  __send__(pow_model_id_column) != my{id} ) 
        }

        potential = self.class.where{
          ( __send__(table).__send__(pow_model_id_column).in(buddies_relations.select{friend_id} ) ) &
          (  __send__(table).pending == false) &
          (  __send__(table).friend_id.in(approved_friendships.select{friend_id} ) ) &
          (  __send__(table).__send__(pow_model_id_column)  != my{id} ) &
          (  __send__(table).__send__(pow_model_id_column).not_in(pending_friendships.select{ __send__(table).__send__(pow_model_id_column)} ) ) &
          (  __send__(table).__send__(pow_model_id_column).not_in(pending_friendships.select{ __send__(table).friend_id} ) ) & 
          (  __send__(table).__send__(pow_model_id_column).not_in(approved_friendships.select{ __send__(table).friend_id} ) ) 

        }.select{ 
          if ActiveRecord::Base.connection.instance_values["config"][:adapter] == 'mysql2'
            ["#{self_table}.id", "#{self_table}.*", "COUNT(`#{__send__(table)}`.`user_id`) as jcount"]
          else
            ["#{self_table}.id", "#{self_table}.*", __send__(table).count.as(:jcount)]
          end

        }.joins(:friendships).group{ 
          [__send__(table).__send__(pow_model_id_column), "#{self_table}.id"]

        }.order("jcount DESC")

        potential
      end


      def create_complimentary_friendship(friendship)
        return false if friendship.pending?
        return pow_friendship_model.create(pow_model_id => friendship.friend_id, 
          friend_id: friendship.send(pow_model_id), pending: false)
      end

      def destroy_complimentary_friendship(friendship)
        return false if friendship.pending?
        friendship_compliment = find_friendship_complement friendship
        return friendship_compliment.destroy
      end

      def find_friendship_complement friendship
        friendship = pow_friendship_model.where(pow_model_id => friendship.friend_id, :friend_id => friendship.send(pow_model_id)).first
      end

      def find_any_friendship_with(model)
        pow_model_id_column = pow_model_id # TODO figure out how to avoid this
        friendship = pow_friendship_model.where{
          (( __send__(pow_model_id_column) == my{id} )  & 
            (  friend_id == my{model.id} )) |
          (( __send__(pow_model_id_column) == my{model.id} )  & 
            (  friend_id == my{id} ))
          }.order(created_at: :desc).first;

        friendship
      end
    end
  end
end

  ActiveRecord::Base.send :include, PowerOfFriendship::ActsAsFriend
