FactoryGirl.define do

  factory :friendship, :class => TestUserFriendship do
    association :test_user, factory: :test_user
    association :friend, factory: :test_user
    pending true
  end
end