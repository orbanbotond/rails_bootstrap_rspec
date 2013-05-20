FactoryGirl.define do

  factory :client do |f|
    f.name {Faker::Name.name}
    f.authentication_key "auth_key"
    f.account_status "Active"
    f.comment Faker::Lorem.paragraph
  end

end