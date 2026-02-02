# spec/factories/events.rb
FactoryBot.define do
  factory :event do
    title { Faker::Kpop.boy_bands }
    description { Faker::Lorem.paragraph }
    start_time { Faker::Time.forward(days: 30, period: :morning) }
    capacity { 100 }
    price { 49.99 }

    # Links to the User factory using the :organizer trait you just built
    association :organizer, :organizer, factory: :user

    trait :full do
      capacity { 0 }
    end
  end
end
