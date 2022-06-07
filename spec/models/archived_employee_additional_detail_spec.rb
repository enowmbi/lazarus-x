require 'rails_helper'

RSpec.describe ArchivedEmployeeAdditionalDetail, type: :model do
  describe "Database(columns and indices)" do
    it { is_expected.to have_db_column(:additional_info).of_type(:string) }
    it { is_expected.to have_db_index(:additional_field_id) }
    it { is_expected.to have_db_index(:archived_employee_id) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:archived_employee) }
    it { is_expected.to belong_to(:additional_field) }
  end
end
