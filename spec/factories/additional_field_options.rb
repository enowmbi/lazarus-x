FactoryBot.define do
  factory :additional_field_option do
    # additional_field { nil }
    additional_field
    field_option { "MyString" }
    school_id { 1 }
  end
end
