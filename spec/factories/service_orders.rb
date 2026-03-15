FactoryBot.define do
  factory :service_order do
    code { Faker::Alphanumeric.alphanumeric(number: 10) }
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    deadline { Faker::Date.forward(days: 30) }
    status { ServiceOrder.statuses.keys.sample }
    priority { ServiceOrder.priorities.keys.sample }
    observations { Faker::Lorem.paragraph }
    property { create(:property) }
    producer { create(:producer) }
    service_provider { create(:service_provider) }
    requested_by { create(:user) }
    assigned_to { create(:user) }
  end
end
