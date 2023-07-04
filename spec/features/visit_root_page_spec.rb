require 'rails_helper'

RSpec.feature "visit_root_page", type: :feature do
  scenario "successfully" do
    visit root_path
    expect(page).to have_css "h1", text: "Fedena"
  end
end
