require 'rails_helper'

RSpec.describe Finance::FinanceFeeCollection, type: :model do
  describe "Database(columns and indices)" do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:start_date).of_type(:date) }
    it { is_expected.to have_db_column(:end_date).of_type(:date) }
    it { is_expected.to have_db_column(:due_date).of_type(:date) }
    it { is_expected.to have_db_column(:fee_category_id).of_type(:integer) }
    it { is_expected.to have_db_column(:batch_id).of_type(:integer) }
    it { is_expected.to have_db_column(:is_deleted).of_type(:boolean) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }

  end

  describe "Associations" do
    it { is_expected.to belong_to(:batch) }
    it { is_expected.to belong_to(:fee_category) }
    it { is_expected.to have_one(:event) }
    it { is_expected.to have_many(:finance_fees).dependent(:destroy) }
    it { is_expected.to have_many(:fee_collection_discounts).dependent(:destroy) }
    it { is_expected.to have_many(:fee_collection_particulars).dependent(:destroy) }
    it { is_expected.to have_many(:students).through(:finance_fees).dependent(:destroy) }
    it { is_expected.to have_many(:finance_transactions).through(:finance_fees).dependent(:destroy) }
  end
end
