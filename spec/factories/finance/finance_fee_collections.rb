FactoryBot.define do
  factory :finance_fee_collection, class: 'Finance::FinanceFeeCollection' do
    name { "MyString" }
    start_date { "2022-06-20" }
    end_date { "2022-06-20" }
    due_date { "2022-06-20" }
    fee_category
    batch
    is_deleted { false }
  end
end
