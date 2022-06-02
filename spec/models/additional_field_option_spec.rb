require 'rails_helper'

RSpec.describe AdditionalFieldOption, type: :model do
  describe "Database(columns and index)" do
    it { is_expected.to have_db_column(:field_option).of_type(:string) }
    it { is_expected.to have_db_column(:school_id).of_type(:integer) }
    it { is_expected.to have_db_index(:additional_field_id) }
  end

  describe "Associations" do
    it { is_expected.to belong_to(:additional_field) }
  end
end
