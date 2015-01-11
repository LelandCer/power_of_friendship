FactoryGirl.define do



  factory :test_user do
    sequence(:name)  { |n|  "Person #{n}" }
  end



end
