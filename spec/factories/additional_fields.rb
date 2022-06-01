FactoryBot.define do
  factory :additional_field do
    name { "MyString" }
    status { false }
    is_mandatory { false }
    input_type { "MyString" }
    priority { 1 }
  end
end
