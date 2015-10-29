require "test_helper"

class CanRecommendTopicsTest < Capybara::Rails::TestCase
  test "sanity" do
    visit root_path
    assert_content page, "OYACO"
  end

  test "user enters valid input" do
    visit root_path
    within '#question-form' do
#      fill_in 'dad', with: '1960-10-10'
#      fill_in 'mom', with: '1960-10-10'

      fill_in 'dad_year', with: '1960'
      fill_in 'dad_month', with: '10'
      fill_in 'dad_day', with: '10'

      fill_in 'mom_year', with: '1960'
      fill_in 'mom_month', with: '10'
      fill_in 'mom_day', with: '10'


      select '北海道', from: 'pref_id'
      click_button 'recommend'
    end

    # TODO: check birthday
    assert_content page, "北海道"
  end
end
