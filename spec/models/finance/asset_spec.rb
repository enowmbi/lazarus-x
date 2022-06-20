require 'rails_helper'

RSpec.describe Finance::Asset, type: :model do
  describe "Database(columns and indices)" do
    it { is_expected.to have_db_column(:title).of_type(:string) }
    it { is_expected.to have_db_column(:description).of_type(:text) }
    it { is_expected.to have_db_column(:amount).of_type(:integer) }
    it { is_expected.to have_db_column(:is_inactive).of_type(:boolean) }
    it { is_expected.to have_db_column(:is_deleted).of_type(:boolean) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:amount) }
    it { is_expected.to validate_numericality_of(:amount) }
  end
end
