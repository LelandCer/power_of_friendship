require_relative '../spec_helper'
require 'rake'


describe TestUser, :type => :model do
  before do
    @user = FactoryGirl.create(:test_user, {name: 'user'})
  end

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:friends) }
  it { should respond_to(:friendships) }
  it { should respond_to(:inverse_friendships) }
  it { should respond_to(:friends) }
  it { should respond_to(:pending_friends) }
  it { should respond_to(:invited_friends) }

  it "should be true" do
    expect(true).to be true
  end

  it "should be false" do
    expect(false).to be false
  end

  describe "friend" do
    before do
      @friend = FactoryGirl.create(:test_user)
      @approved_friendship = FactoryGirl.create(:friendship, {test_user: @user, friend: @friend, pending: false})
      FactoryGirl.create(:friendship, {test_user: @friend, friend: @user, pending: false})
    end

    it "should respond to friends_with?" do 
      expect(@user.friends_with? @friend).to be true
    end

    it "reverse should respond to friends_with?" do 
      expect(@friend.friends_with? @user).to be true
    end
    it "should respond to connected_with?" do 
      expect(@user.connected_with? @friend).to be true
    end

    describe do
      subject { @friend }

      it{ should be_in @user.friends }
      it{ should_not be_in @user.pending_friends }
      it{ should_not be_in @user.invited_friends }
    end

    describe do
      subject { @approved_friendship }

      it{ should be_in @user.approved_friendships }
      it{ should_not be_in @user.pending_friendships }
      it{ should_not be_in @user.invited_friendships }
    end
  end

  describe "pending" do
    before do
      @pending_friend = FactoryGirl.create(:test_user)
      @pending_friendship = FactoryGirl.create(:friendship, {test_user: @pending_friend, friend: @user})
    end

    it "should respond to connected_with?" do 
      expect(@user.connected_with? @pending_friend).to be true
    end

    describe do
      subject { @pending_friend }

      it{ should be_in @user.pending_friends}
      it{ should_not be_in @user.friends}
      it{ should_not be_in @user.invited_friends}
    end

    describe do
      subject { @pending_friendship }

      it{ should be_in @user.pending_friendships}
      it{ should_not be_in @user.approved_friendships}
      it{ should_not be_in @user.invited_friendships}
    end
  end

  describe "invited" do
    before do
      @invited_friend = FactoryGirl.create(:test_user)
      @invited_friendship =FactoryGirl.create(:friendship, {test_user: @user, friend: @invited_friend})
    end

    it "should respond to connected_with?" do 
      expect(@user.connected_with? @invited_friend).to be true
    end

    describe do
      subject { @invited_friend }

      it{ should be_in @user.invited_friends}
      it{ should_not be_in @user.friends}
      it{ should_not be_in @user.pending_friends}
    end

    describe do
      subject { @invited_friendship }

      it{ should be_in @user.invited_friendships}
      it{ should_not be_in @user.approved_friendships}
      it{ should_not be_in @user.pending_friendships}
    end

  end

  describe "inviting a friend" do 
    before do
      @friend = FactoryGirl.create(:test_user)
      @user.invite @friend
    end
    describe do
      subject { @user }
      
      it{ should be_in @friend.pending_friends}
      it{ should_not be_in @user.friends}
      it{ should_not be_in @user.invited_friends}

      it "user should have invited friend" do
        expect(@user.invited? @friend).to be true
      end
      it "user should not have been invited by friend" do
        expect(@friend.invited? @user).to be false
      end

    end
    describe do
      subject { @friend }
      
      it{ should be_in @user.invited_friends}
      it{ should_not be_in @user.friends}
      it{ should_not be_in @user.pending_friends}

      it "friend should have been invited by user" do
        expect(@friend.invited_by? @user).to be true
      end

      it "user should not have been invited by friend" do
        expect(@user.invited_by? @friend).to be false
      end

    end
  end

  describe "approving a friend" do 
    before do
      @friend = FactoryGirl.create(:test_user)
      @user.invite @friend
    end

    it "should approve" do
      expect(@friend.approve @user).to be true
    end
    describe do
      before { @friend.approve @user }
      describe do
        subject { @user }
        
        it{ should be_in @friend.friends}
        it{ should_not be_in @user.pending_friends}
        it{ should_not be_in @user.invited_friends}

        it "user should have invited friend" do
          expect(@user.invited? @friend).to be true
        end

        it "user should not have been invited by friend" do
          expect(@friend.invited? @user).to be false
        end
      end
      describe do
        subject { @friend }
        
        it{ should be_in @user.friends}
        it{ should_not be_in @user.invited_friends}
        it{ should_not be_in @user.pending_friends}

        it "friend should have been invited by user" do
          expect(@friend.invited_by? @user).to be true
        end

        it "user should not have been invited by friend" do
          expect(@user.invited_by? @friend).to be false
        end
      end

      it "should have the friendship" do
        friendship = "TestUserFriendship".constantize.where(test_user_id: @user.id, friend_id: @friend.id, pending: false).first
        expect(friendship).to_not be nil
      end
      it "should have the inverse friendship" do
        friendship = "TestUserFriendship".constantize.where(friend_id: @user.id, test_user_id: @friend.id, pending: false).first
        expect(friendship).to_not be nil
      end
    end
  end


  describe "disapproving a friend" do 
    before do
      @friend = FactoryGirl.create(:test_user)
      @user.invite @friend
      @friend.unfriend @user
    end

    it "should not approve" do
      expect(@friend.approve @user).to be false
    end
   
    it "should not be connected_with" do
      expect(@friend.connected_with? @user).to be false
    end
   
  end

  describe "removing a friend" do 
    before do
      @friend = FactoryGirl.create(:test_user)
      @user.invite @friend
      @friend.approve @user
      @friend.unfriend @user
    end
   
    it "should not be connected_with" do
      expect(@friend.connected_with? @user).to be false
    end
   
  end





  describe "inverse friendships" do
    before { 
      @inverse_friendship = FactoryGirl.create(:friendship, {friend: @user})
    }

    subject { @inverse_friendship }
    it{ should be_in @user.inverse_friendships}
  end

  describe "inviting a friend" do 
    before { 
      @friendship = FactoryGirl.create(:friendship, {test_user: @user})
    }

    subject { @friendship }
    it{ should be_in @user.friendships}

    it "friendship user should be user" do
      expect(@friendship.test_user).to be @user
    end
  end

  describe "inverse friendships" do
    before { 
      @inverse_friendship = FactoryGirl.create(:friendship, {friend: @user})
    }

    subject { @inverse_friendship }
    it{ should be_in @user.inverse_friendships}
  end

  describe "followers" do

    describe "through friendship"
    before do
      @follower_approved = FactoryGirl.create(:test_user)
      @follower_approved_inverse = FactoryGirl.create(:test_user)
      @follower_pending = FactoryGirl.create(:test_user)

      @follower_pending.invite @user
      @follower_approved.invite @user
      @user.invite @follower_approved_inverse
      @user.approve @follower_approved
      @follower_approved_inverse.approve @user
    end

    it "follower_approved should be in followers" do
      expect(@follower_approved).to be_in @user.followers
    end
    it "follower_approved_inverse should be in followers" do
      expect(@follower_approved_inverse).to be_in @user.followers
    end
    it "follower_pending should be in followers" do
      expect(@follower_pending).to be_in @user.followers
    end
  end

  describe do
    before do
      @follower = FactoryGirl.create(:test_user)
      @inverse_follower = FactoryGirl.create(:test_user)
    end

    it "follow should follow" do
      expect(@follower.follow @user).to_not be false
    end

    it "inverse_follower should follow" do
      expect(@user.follow @inverse_follower).to_not be false
    end

    it "should be able to follow back" do
      expect(@inverse_follower.follow @user).to_not be false
      expect(@user.follow @inverse_follower).to_not be false
    end

    describe do
      before do
        @follower.follow @user
        @user.follow @inverse_follower
      end

      it "follower should be in followers" do
        expect(@follower).to be_in @user.followers
      end

      it "inverse_follower should not be in followers" do
        expect(@inverse_follower).to_not be_in @user.followers
      end

      it "user should be in inverse_follower followers" do
        expect(@user).to be_in @inverse_follower.followers
      end

      it "user should be in follower inverse_followers" do
        expect(@user).to be_in @follower.inverse_followers
      end

      it "user should be in follower inverse_followers" do
        expect(@user).to be_in @follower.inverse_followers
      end

      it "user should not be in follower followers" do
        expect(@user).to_not be_in @follower.followers
      end


      it "follower should respond to follow?" do
        expect(@follower.follows? @user).to be true
      end
      it "user should respond to follow?" do
        expect(@user.follows? @inverse_follower).to be true
      end

      it "follower should respond to followed_by?" do
        expect(@inverse_follower.followed_by? @user).to be true
      end

      it "user should respond to followed_by?" do
        expect(@user.followed_by? @follower).to be true
      end
    end

    describe "unfollowing" do
      before do
        @follower = FactoryGirl.create(:test_user)
        @inverse_follower = FactoryGirl.create(:test_user)
        @follower.follow @inverse_follower
        @inverse_follower.follow @follower
      end

      describe "@follower unfollows" do
        before do
          @follower.unfollow @inverse_follower
        end

        it "should not follow" do
          expect(@follower.follows? @inverse_follower).to be false
        end

        it "should still be followed" do 
          expect(@follower.followed_by? @inverse_follower).to be true
        end

        it "should now have a pending friendship" do
          expect(@follower.find_any_friendship_with(@inverse_follower).pending?).to be true
        end
      end

      describe "@inverse_follower unfollows" do
        before do
          @inverse_follower.unfollow @follower
        end

        it "should not follow" do
          expect(@inverse_follower.follows? @follower).to be false
        end

        it "should still be followed" do 
          expect(@inverse_follower.followed_by? @follower).to be true
        end

        it "should now have a pending friendship" do
          expect(@inverse_follower.find_any_friendship_with(@follower).pending?).to be true
        end
      end

    end

    describe "friendship api should still function" do
      before do 
        @mutual = FactoryGirl.create(:test_user)
        @follower.follow @user
        @user.follow  @inverse_follower
        @mutual.follow @user
        @user.follow @mutual
      end

      it "user should be friends with mutual" do
        expect(@user.friends_with? @mutual).to be true
      end

      it "mutual should be friends with user" do
        expect(@mutual.friends_with? @user).to be true
      end

      it "follower should be in pending" do
        expect(@follower).to be_in @user.pending_friends
      end

      it "inverse_follower should be in invited_friends" do
        expect(@inverse_follower).to be_in @user.invited_friends

      end
    end

    describe "suggested friends" do
      before  do
        @first_suggested = FactoryGirl.create(:test_user, {name: 'first_suggested' })
        @second_suggested = FactoryGirl.create(:test_user, {name: 'second_suggested'})
        @third_suggested = FactoryGirl.create(:test_user, {name: 'third_suggested'})
        @first_pending = FactoryGirl.create(:test_user)
        @second_pending = FactoryGirl.create(:test_user)
        @friends = FactoryGirl.create_list(:test_user, 10)

        @friends[0..4].each do |new_friend|
          friend new_friend, @user
          friend @first_suggested, new_friend
        end 
        @friends[5..9].each do |new_friend|
          friend @user, new_friend
          friend new_friend, @first_suggested
        end 


        friend @second_suggested, @friends[0]
        friend @second_suggested, @friends[1]
        friend @friends[2], @second_suggested

        friend @third_suggested, @friends[1]
        friend @friends[2], @third_suggested

        @friends.each do |friend1|
          @friends.each do |friend2|
            friend friend1, friend2
          end  
        end  

        @user.invite @first_pending
        @second_pending.invite @user

        @friends[0].invite @first_pending
        @first_pending.approve @friends[0]
        @friends[1].invite @second_pending
        @second_pending.approve @friends[1]
      end

      # after :all do
      #   User.destroy_all
      # end
      subject{@user}

      it { should respond_to(:suggested_friends) }

      it "suggested_friends should run" do
        # TODO remove test
        expect(@user.suggested_friends).to_not be false
      end

      it "should have first suggested" do
        expect(@first_suggested).to be_in @user.suggested_friends
      end

      it "should have second suggested" do
        expect(@second_suggested).to be_in @user.suggested_friends
      end

      it "should have third suggested" do
        expect(@third_suggested).to be_in @user.suggested_friends
      end


      it "should not have first pending" do
        expect(@first_pending).to_not be_in @user.suggested_friends
      end

      it "should not have second pending" do
        expect(@second_pending).to_not be_in @user.suggested_friends
      end

      it "should not have user" do
        expect(@user).to_not be_in @user.suggested_friends
      end

      it "should not have user friends" do
        @friends.each { |friend|  
        expect(friend).to_not be_in @user.suggested_friends

        }
      end

      it "should have first suggested first" do
        expect(@user.suggested_friends[0]).to eq @first_suggested
      end

      it "should have second suggested second" do
        expect(@user.suggested_friends[1]).to eq @second_suggested
      end

      it "should have third suggested third" do
        expect(@user.suggested_friends[2]).to eq  @third_suggested
      end

      it "should have only three friends" do
        expect(@user.suggested_friends.reorder("test_users.id").size.length).to eq 3
      end
    end
  end
end
def friend one, two
  one.invite two
  two.approve one
end