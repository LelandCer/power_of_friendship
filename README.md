Power of Friendship
================

Power of Friendship is a friendship library for Rails' Active Records. It allows you to add Facebook style friendships and/or Twitter style followers to any model.

-----

Installation
--------------

> gem install "power_of_friendship", "~> 1.0.0"

Quick Start
-------------
Let's say we want to add friendships to a User model.

> rails generate friendship User

This creates the following migration:
```ruby
 class CreateUserFriendship < ActiveRecord::Migration
  def change
    create_table :user_friendships do |t|
      t.belongs_to :user, index: true
      t.belongs_to :friend, index: true
      t.boolean :pending, :default => true
      t.timestamps
    end
    add_index :user_friendships, [:user_id, :friend_id], :unique => true
  end
end
```
and the following model:
```ruby
class UserFriendship < ActiveRecord::Base
  belongs_to :user 

  belongs_to :friend,
    :class_name => User ,
    :foreign_key => :friend_id


  validates_presence_of :friend_id, :user_id
  validates_uniqueness_of :user_id, :scope => :friend_id

  def approved?
    !self.pending
  end

  def pending?
    self.pending
  end
end
```

Now add:
> act_as_friend

to your model:
```ruby
class User < ActiveRecord::Base
    act_as_friend
end
```

Now just run
>rake db:migrate

and you're good to go.

----
#### **Friends**

```ruby
@user.invite @friend # invite a friend. 
@friend.approve @user # approve a friendship
@user.unfriend @friend # destroys friendship

@user.friends # returns users who have approved your friendship
@user.invited_friends # returns users who you've invited to be friends
@user.pending_friends # returns users who have invited you to be their friend
@user.suggested_friends # returns users who share mutual friends with you, ordered by number of common friends

@user.friends_with? @friend # returns true if approved friendship exists between @user and @friend
@user.invited? @friend # returns true if @user invited @friend
@user.invited_by? @friend # returns true if @friend invited @user
@user.connected_with? @friend # returns true if either an invitation or a friendship exists

```

----
#### **Followers**

```ruby
@user.follow @other_user 
@user.unfollow @other_user

@user.follows? @other_user 
@user.followed_by? @other_user

@user.followers # returns users who follow @user
@user.inverse_followers # returns users who @user follows
```
note: following a user who is not a follow is identical to .invite; following a user who is a follower is identical to .approve