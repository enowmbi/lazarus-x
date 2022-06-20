require 'rails_helper'

RSpec.describe StudentCategory, type: :model do
  describe "Database(columns and indices)" do
    it { is_expected.to have_db_column(:name).of_type(:name) }
    it { is_expected.to have_db_column(:is_deleted).of_type(:boolean) }
  end
end
