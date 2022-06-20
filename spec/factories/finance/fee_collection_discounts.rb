FactoryBot.define do
  factory :fee_collection_discount, class: "Finance::FeeCollectionDiscount" do
    type { "" }
    name { "MyString" }
    receiver_id { "" }
    finance_fee_collection
    discount { "9.99" }
    is_amount { false }
  end
end
