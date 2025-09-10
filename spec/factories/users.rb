FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.unique.email }
    age { Faker::Number.between(from: 18, to: 80) }
  end
end
