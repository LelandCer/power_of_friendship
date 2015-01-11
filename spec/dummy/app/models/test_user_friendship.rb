class TestUserFriendship < ActiveRecord::Base
  belongs_to :test_user 

  belongs_to :friend,
    :class_name => TestUser ,
    :foreign_key => :friend_id


  validates_presence_of :friend_id, :test_user_id
  validates_uniqueness_of :test_user_id, :scope => :friend_id

  def approved?
    !self.pending
  end

  def pending?
    self.pending
  end
end
