# spec/factories/bookings.rb
FactoryBot.define do
  factory :booking do
    association :user # Defaults to customer role
    association :event
    status { :pending }
    payment_intent_id { "pi_#{SecureRandom.hex(10)}" }

    trait :confirmed do
      status { :confirmed }
    end
  end
end
