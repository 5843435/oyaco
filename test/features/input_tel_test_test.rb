# -*- coding: utf-8 -*-
require "test_helper"

class InputTelTestTest < Capybara::Rails::TestCase
  test "user inputs valid number with smartphone" do
    page.driver.browser.header('User-Agent', "Mozilla/5.0 (Linux; U; Android 2.2.1; en-us; Nexus One Build/FRG83) AppleWebKit/533.1 (KHTML, like Gecko) Version/4.0 Mobile Safari/533.1")

    visit root_path
    click_on 'try'
    click_on 'next'
    click_on 'next'
    within '#question-form' do
      select '東京都', from: 'questionnaire_pref_code'
    end
    click_on 'next'
    within '#question-form' do
      fill_in 'questionnaire_tel', with: '00-0000-0000'
    end
    click_on 'next'
    click_on 'go-home'
    assert_nil page.find('#tel')[:class]
  end

  test "user doesn't input number" do
    visit root_path
    click_on 'try'
    click_on 'next'
    click_on 'next'
    click_on 'next'
    within '#question-form' do
      fill_in 'questionnaire_tel', with: ''
      click_on 'next'
    end
    click_on 'go-home'
    assert page.find('#tel')[:class].include?("disabled")
  end

  test "user inputs valid number with PC" do
    page.driver.browser.header('User-Agent', "Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; WOW64; Trident/6.0)")
    visit root_path
    click_on 'try'
    click_on 'next'
    click_on 'next'
    click_on 'next'
    within '#question-form' do
      fill_in 'questionnaire_tel', with: '00-0000-0000'
      click_on 'next'
    end
    click_on 'go-home'
    assert page.find('#tel')[:class].include?("disabled")
  end
end
