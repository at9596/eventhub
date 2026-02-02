# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    sequence(:email) { |n| "#{Faker::Internet.username}#{n}@example.com" }
    password { "password123" }
    role { :customer } # Default to the most common role

    trait :admin do
      role { :admin }
    end

    trait :organizer do
      role { :organizer }
    end
  end
end
