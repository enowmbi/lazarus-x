FactoryBot.define do
  factory :finance_asset, class: 'Finance::Asset' do
    title { "MyString" }
    amount { 1 }
    description { "MyText" }
    is_inactive { false }
    is_deleted { false }
  end
end
