require "test_helper"

class RememberInputsTest < Capybara::Rails::TestCase
  test "remember inputs via cookie" do
    visit root_path
    within '#question-form' do
      fill_in 'dad', with: '1960-10-10'
      fill_in 'mom', with: '1960-10-10'
      select '東京都', from: 'pref_id'
      click_button 'recommend'
    end

    visit root_path

    within '#question-form' do
      assert_equal find_field('dad').value, '1960-10-10'
      assert_equal find_field('mom').value, '1960-10-10'
      assert_equal find_field('pref_id').value, JpPrefecture::Prefecture.find(name: "東京都").code.to_s
    end
  end

  test "forget cookie and set to default" do
    visit root_path
    within '#question-form' do
      fill_in 'dad', with: '1960-10-10'
      fill_in 'mom', with: '1960-10-10'
      select '東京都', from: 'pref_id'
      click_button 'recommend'
    end

    Capybara.current_session.reset!
    
    visit root_path

    within '#question-form' do
      assert_equal find_field('dad').value, '1950-12-31'
      assert_equal find_field('mom').value, '1950-12-31'
      assert_equal find_field('pref_id').value, JpPrefecture::Prefecture.find(name: "北海道").code.to_s
    end
  end
end
