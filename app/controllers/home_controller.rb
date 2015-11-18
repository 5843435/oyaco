class HomeController < ApplicationController
  #  before_action :authenticate_user!, only: :show

  def index
    return redirect_to home_path if user_signed_in?
  end

  def show
    return redirect_to root_path if !user_signed_in? && !cookies.signed[:pref_id]

    questionnaire = Questionnaire.new
    questionnaire.restore_attributes_from_cookies(cookies)
    build_topics(questionnaire) if questionnaire.present?
  end

  private

  def build_topics(questionnaire)
    @pref_id = questionnaire.pref_id

    remind_months_ago = Oyaco::Application.config.remind_months_ago
    @topics = []

    if user_signed_in?
      father = current_user.people.father.first
      mother = current_user.people.mother.first
    else
      father = Person.new
      father.assign_attributes(relation: Person.relations[:father],
                               birthday: questionnaire.dad,
                               location: questionnaire.pref_id)
      mother = Person.new
      mother.assign_attributes(relation: Person.relations[:mother],
                               birthday: questionnaire.mom,
                               location: questionnaire.pref_id)
    end

    [father, mother].each do |person|
      next unless person.present?
      if person.birthday?
        if person.next_birthday < Date.current.months_since(remind_months_ago)
          @topics.push(
            title: "もうすぐ #{person.friendly_name} の #{person.age + 1} 歳の誕生日（#{person.next_birthday.strftime('%-m月%e日')})",
            comment: ("こんなプレゼントはいかがですか？<br>" + get_comment_by_age(person.age + 1)).html_safe,
            items: RakutenWebService::Ichiba::Item.ranking(age: person.rakuten_age, sex: person.gender))
        end
      end
    end

    # 祝日関連の話題
    @holidays = Holiday.soon
    @holidays.each do |holiday|
      @topics.push(
        title: holiday.date.strftime('%Y年%-m月%e日') + 'は' + holiday.name,
        name: holiday.name,
        comment: EventData.find_by_name(holiday.name).try(:comment),
        wikipedia: EventData.find_by_name(holiday.name).try(:wikipedia),
        items: (RakutenWebService::Ichiba::Item.search(keyword: holiday.name) unless holiday.name == '元日'),
        message: EventData.find_by_name(holiday.name).try(:message))
    end

    # Local
    if @pref_id.present?
      @pref_name = PrefName.get_pref_name(@pref_id)
      @warnings = LocalInfo.get_weather_warnings(@pref_id)
      @message = MessageGenerator.new(@warnings).generate
      @googlenews = LocalInfo.get_local_news(@pref_name)
    end

    # 趣味
    @hobbys = []
    if questionnaire.hobby.present?
      @hobbys.push(
        name: questionnaire.hobby,
        news: LocalInfo.get_hobby_news(questionnaire.hobby)
      )
    end
    if questionnaire.hobby2.present?
      @hobbys.push(
        name: questionnaire.hobby2,
        news: LocalInfo.get_hobby_news(questionnaire.hobby2)
      )
    end
    if questionnaire.hobby3.present?
      @hobbys.push(
        name: questionnaire.hobby3,
        news: LocalInfo.get_hobby_news(questionnaire.hobby3)
      )
    end
    # 電話番号
    @tel = questionnaire.tel || ''
  end
end

def get_comment_by_age(age)
  case age
  when 61
    '61歳は還暦です。【出典・由来】干支が60年後に出生時の干支に還って（かえって）くるので。'
  when 70
    '70歳は古希です。【出典・由来】「人生七十、古来稀なり」の詩（杜甫「曲江」）より。'
  when 77
    '77歳は喜寿です。【出典・由来】「喜」の草体が七十七のように見えるため。'
  when 80
    '80歳は傘寿です。【出典・由来】「傘」の略字（仐）が八十と分解できるため。'
  when 88
    '88歳は米寿です。【出典・由来】「米」の字が八十八と分解できるため。'
  when 90
    '90歳は卒寿です。【出典・由来】「卒」の略字（卆）が九十と分解できるため。'
  when 99
    '99歳は白寿です。【出典・由来】「百」の字から一をとると白になる事から。'
  else
    ''
  end
end
