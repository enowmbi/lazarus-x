FactoryBot.define do
  factory :archived_employee do
    status { true }
    first_name { "Jane" }
    middle_name { "Lucy" }
    last_name { "Doe" }
  end
end
