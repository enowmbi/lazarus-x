FactoryBot.define do
  factory :archived_employee_additional_detail do
    archived_employee
    additional_field
    additional_info { "MyString" }
  end
end
