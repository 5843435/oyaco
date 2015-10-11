class WelcomeController < ApplicationController
  # GET /
  def top
    cookies.signed[:dad] = params[:dad]
    cookies.signed[:mom] = params[:mom]
    cookies.signed[:pref_id] = params[:pref_id]
    cookies.signed[:tel] = params[:tel]

    #リクエストパラメータから都道府県コードを取得する
    @pref_id = params[:pref_id]

    # 誕生日
    @topics_birthday = []

    # FIXME: need to create model
    # 父
    birthdate = params[:dad]
    age = get_age(birthdate)
    age_r = get_rakuten_age(age)
    next_birthday = get_next_birthday(birthdate)
    if next_birthday - 1.months < Date.today
      @topics_birthday.push(
        {
          title: "もうすぐお父さんの" + (age+1).to_s + "歳の誕生日（" + next_birthday.strftime("%-m月%e日") + ") です",
          comment: "こんなプレゼントはいかがですか？",
          items: RakutenWebService::Ichiba::Item.ranking(:age => age_r, :sex => 0)
        })
    end

    # 母  FIXME: DRY
    birthdate = params[:mom]
    age = get_age(birthdate)
    age_r = get_rakuten_age(age)
    next_birthday = get_next_birthday(birthdate)
    if next_birthday - 1.months < Date.today
      @topics_birthday.push(
        {
          title: "もうすぐお母さんの" + (age+1).to_s + "歳の誕生日（" + next_birthday.strftime("%-m月%e日") + ") です",
          comment: "こんなプレゼントはいかがですか？",
          items: RakutenWebService::Ichiba::Item.ranking(:age => age_r, :sex => 1)
        })
    end

    #都道府県コードをもとに都道府県名を取得する
    @pref_name = PrefName.get_pref_name(@pref_id)

    #都道府県コードをもとに警報・注意報を取得する
    @warnings = LocalInfo.get_weather_warnings(@pref_id)

    #コメントを作る
    @message = MessageGenerator.new(@warnings).generate

    #祝日情報を取得する
    @holidays = Holiday.where('holiday_date > ?',Date.today).order('holiday_date')

    #Google search
    @googlenews = LocalInfo.get_google_news(@pref_name)

    #楽天API呼出し用のIDを環境変数から取得する
    RakutenWebService.configuration do |c|
      c.application_id = ENV["APPID"]
      c.affiliate_id = ENV["AFID"]
    end

    @tel = params[:tel]
  end

private
  def get_age(birthdate)
    age = ((Date.today.strftime("%Y%m%d").to_i -
            Date.strptime(birthdate).strftime("%Y%m%d").to_i)/10000)
  end

  def get_rakuten_age(age)
    age_r = age.round(-1)
    if age_r > 50 then age_r = 50 end;
    if age_r == 0 then age_r = 10 end;
    age_r
  end

  def get_next_birthday(birthdate)
    birthday = Date.strptime(birthdate)
    next_birthday = Date.new(Date.today.year, birthday.month, birthday.day)
    if (next_birthday < Date.today)
      next_birthday = Date.new(Date.today.year+1, birthday.month, birthday.day)
    end
    next_birthday
  end
end
