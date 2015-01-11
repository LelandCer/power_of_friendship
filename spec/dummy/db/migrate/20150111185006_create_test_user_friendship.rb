class CreateTestUserFriendship < ActiveRecord::Migration
  def change
    create_table :test_user_friendships do |t|
      t.belongs_to :test_user, index: true
      t.belongs_to :friend, index: true
      t.boolean :pending, :default => true


      t.timestamps

    end

    add_index :test_user_friendships, [:test_user_id, :friend_id], :unique => true
    
  end
end