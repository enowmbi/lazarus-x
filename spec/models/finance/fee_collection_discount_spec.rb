require 'rails_helper'

RSpec.describe Finance::FeeCollectionDiscount, type: :model do
  describe "Database(columns and indices)" do
    it { is_expected.to have_db_column(:type).of_type(:string) }
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:receiver_id).of_type(:integer) }
    it { is_expected.to have_db_column(:discount).of_type(:decimal) }
    it { is_expected.to have_db_column(:is_amount).of_type(:boolean) }
    it { is_expected.to have_db_column(:finance_fee_collection_id).of_type(:integer) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:finance_fee_collection) }
  end

  describe "#category_name" do
    student_category = FactoryBot.build_stubbed(:student_category, name: "New Category")
    fee_collection_discount = FactoryBot.create(:fee_collection_discount)

    expect(fee_collection_discount.category_name).to eq(student_category.name)
  end

  describe "#student_name" do
    student = FactoryBot.build_stubbed(:student, first_name: "John", admission_no: "1234567")
    fee_collection_discount = FactoryBot.create(:fee_collection_discount)

    expect(fee_collection_discount.student_name).to eq("#{student.name} (#{student.admission_no})")
  end
end
