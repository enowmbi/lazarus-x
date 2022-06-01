require 'rails_helper'

RSpec.describe AdditionalField, type: :model do
  describe "Database(column and indices)" do
    it { is_expected.to have_db_column(:name).of_type(:string) }
    it { is_expected.to have_db_column(:status).of_type(:boolean) }
    it { is_expected.to have_db_column(:is_mandatory).of_type(:boolean) }
    it { is_expected.to have_db_column(:input_type).of_type(:string) }
    it { is_expected.to have_db_column(:name).of_type(:string) }

    it { is_expected.to have_db_index(:name).unique(true) }
  end
  describe "Associations" do
    it { is_expected.to have_many(:additional_field_options).dependent(:destroy) }
    it { is_expected.to accept_nested_attributes_for(:additional_field_options).allow_destroy(true) }
  end

  describe "Validations" do
    @name_format = %r{\A[^~`@%$*()\-\[\]{}"':;/.,\\=+|]*\z}i
    xit { is_expected.to validate_format_of(:name).with(@name_format) }
    it { is_expected.to validate_presence_of(:name) }
  end
end
