require 'rails_helper'

RSpec.describe ArchivedEmployee, type: :model do
  describe "Database(columns and indices)" do
    it { is_expected.to have_db_column(:first_name).of_type(:string) }
    it { is_expected.to have_db_column(:middle_name).of_type(:string) }
    it { is_expected.to have_db_column(:last_name).of_type(:string) }
    it { is_expected.to have_before_action(:status_false).on(:save) }
    it { is_expected.to have_before_save(:status_false) }
  end

  describe "Associations" do

  end

  describe "#full_name" do
    
  end


end
