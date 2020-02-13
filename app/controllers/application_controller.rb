class ApplicationController < ActionController::API
  # this helper keeps all logic in one place for creating Slack client objects for each team
  def create_slack_client(slack_api_secret)
    Slack.configure do |config|
        config.token = slack_api_secret
        fail 'Missing API token' unless config.token
    end
    Slack::Web::Client.new
  end

  # load Slack app info into hash called `config` from env vars assigned during setup
  def slack_config
    Dotenv.load('.env')
    slack_config = {
      slack_client_id: ENV['SLACK_CLIENT_ID'],
      slack_api_secret: ENV['SLACK_API_SECRET'],
      slack_redirect_uri: ENV['SLACK_REDIRECT_URI'],
      slack_verification_token: ENV['SLACK_VERIFICATION_TOKEN'],
      slack_bot_user_oauth_access_token: ENV['BOT_USER_OAUTH_ACCESS_TOKEN']
    }
  end

  def bot_slack_client
    bot_token = slack_config[:slack_bot_user_oauth_access_token]
    Slack::Web::Client.new(token: bot_token)
  end

  # check to see if required vars listed above were provided, raise exception if missing
  def missing_params_check
    missing_params = slack_config.select{ |key, value| value.nil? }
    if missing_params.any?
      error_msg = missing_params.keys.join(", ").upcase
      raise "Missing Slack config variables: #{error_msg}"
    end
  end

  def format_unix_to_normal_time(unix_time, time_zone = "PST")
    native_timezones = {
      "International Date Line West"=>"Pacific/Midway",
      "Midway Island"=>"Pacific/Midway",
      "American Samoa"=>"Pacific/Pago_Pago",
      "Hawaii"=>"Pacific/Honolulu",
      "Alaska"=>"America/Juneau",
      "Pacific Time (US & Canada)"=>"America/Los_Angeles",
      "Tijuana"=>"America/Tijuana",
      "Mountain Time (US & Canada)"=>"America/Denver",
      "Arizona"=>"America/Phoenix",
      "Chihuahua"=>"America/Chihuahua",
      "Mazatlan"=>"America/Mazatlan",
      "Central Time (US & Canada)"=>"America/Chicago",
      "Saskatchewan"=>"America/Regina",
      "Guadalajara"=>"America/Mexico_City",
      "Mexico City"=>"America/Mexico_City",
      "Monterrey"=>"America/Monterrey",
      "Central America"=>"America/Guatemala",
      "Eastern Time (US & Canada)"=>"America/New_York",
      "Indiana (East)"=>"America/Indiana/Indianapolis",
      "Bogota"=>"America/Bogota",
      "Lima"=>"America/Lima",
      "Quito"=>"America/Lima",
      "Atlantic Time (Canada)"=>"America/Halifax",
      "Caracas"=>"America/Caracas",
      "La Paz"=>"America/La_Paz",
      "Santiago"=>"America/Santiago",
      "Newfoundland"=>"America/St_Johns",
      "Brasilia"=>"America/Sao_Paulo",
      "Buenos Aires"=>"America/Argentina/Buenos_Aires",
      "Montevideo"=>"America/Montevideo",
      "Georgetown"=>"America/Guyana",
      "Greenland"=>"America/Godthab",
      "Mid-Atlantic"=>"Atlantic/South_Georgia",
      "Azores"=>"Atlantic/Azores",
      "Cape Verde Is."=>"Atlantic/Cape_Verde",
      "Dublin"=>"Europe/Dublin",
      "Edinburgh"=>"Europe/London",
      "Lisbon"=>"Europe/Lisbon",
      "London"=>"Europe/London",
      "Casablanca"=>"Africa/Casablanca",
      "Monrovia"=>"Africa/Monrovia",
      "UTC"=>"Etc/UTC",
      "Belgrade"=>"Europe/Belgrade",
      "Bratislava"=>"Europe/Bratislava",
      "Budapest"=>"Europe/Budapest",
      "Ljubljana"=>"Europe/Ljubljana",
      "Prague"=>"Europe/Prague",
      "Sarajevo"=>"Europe/Sarajevo",
      "Skopje"=>"Europe/Skopje",
      "Warsaw"=>"Europe/Warsaw",
      "Zagreb"=>"Europe/Zagreb",
      "Brussels"=>"Europe/Brussels",
      "Copenhagen"=>"Europe/Copenhagen",
      "Madrid"=>"Europe/Madrid",
      "Paris"=>"Europe/Paris",
      "Amsterdam"=>"Europe/Amsterdam",
      "Berlin"=>"Europe/Berlin",
      "Bern"=>"Europe/Berlin",
      "Rome"=>"Europe/Rome",
      "Stockholm"=>"Europe/Stockholm",
      "Vienna"=>"Europe/Vienna",
      "West Central Africa"=>"Africa/Algiers",
      "Bucharest"=>"Europe/Bucharest",
      "Cairo"=>"Africa/Cairo",
      "Helsinki"=>"Europe/Helsinki",
      "Kyiv"=>"Europe/Kiev",
      "Riga"=>"Europe/Riga",
      "Sofia"=>"Europe/Sofia",
      "Tallinn"=>"Europe/Tallinn",
      "Vilnius"=>"Europe/Vilnius",
      "Athens"=>"Europe/Athens",
      "Istanbul"=>"Europe/Istanbul",
      "Minsk"=>"Europe/Minsk",
      "Jerusalem"=>"Asia/Jerusalem",
      "Harare"=>"Africa/Harare",
      "Pretoria"=>"Africa/Johannesburg",
      "Kaliningrad"=>"Europe/Kaliningrad",
      "Moscow"=>"Europe/Moscow",
      "St. Petersburg"=>"Europe/Moscow",
      "Volgograd"=>"Europe/Volgograd",
      "Samara"=>"Europe/Samara",
      "Kuwait"=>"Asia/Kuwait",
      "Riyadh"=>"Asia/Riyadh",
      "Nairobi"=>"Africa/Nairobi",
      "Baghdad"=>"Asia/Baghdad",
      "Tehran"=>"Asia/Tehran",
      "Abu Dhabi"=>"Asia/Muscat",
      "Muscat"=>"Asia/Muscat",
      "Baku"=>"Asia/Baku",
      "Tbilisi"=>"Asia/Tbilisi",
      "Yerevan"=>"Asia/Yerevan",
      "Kabul"=>"Asia/Kabul",
      "Ekaterinburg"=>"Asia/Yekaterinburg",
      "Islamabad"=>"Asia/Karachi",
      "Karachi"=>"Asia/Karachi",
      "Tashkent"=>"Asia/Tashkent",
      "Chennai"=>"Asia/Kolkata",
      "Kolkata"=>"Asia/Kolkata",
      "Mumbai"=>"Asia/Kolkata",
      "New Delhi"=>"Asia/Kolkata",
      "Kathmandu"=>"Asia/Kathmandu",
      "Astana"=>"Asia/Dhaka",
      "Dhaka"=>"Asia/Dhaka",
      "Sri Jayawardenepura"=>"Asia/Colombo",
      "Almaty"=>"Asia/Almaty",
      "Novosibirsk"=>"Asia/Novosibirsk",
      "Rangoon"=>"Asia/Rangoon",
      "Bangkok"=>"Asia/Bangkok",
      "Hanoi"=>"Asia/Bangkok",
      "Jakarta"=>"Asia/Jakarta",
      "Krasnoyarsk"=>"Asia/Krasnoyarsk",
      "Beijing"=>"Asia/Shanghai",
      "Chongqing"=>"Asia/Chongqing",
      "Hong Kong"=>"Asia/Hong_Kong",
      "Urumqi"=>"Asia/Urumqi",
      "Kuala Lumpur"=>"Asia/Kuala_Lumpur",
      "Singapore"=>"Asia/Singapore",
      "Taipei"=>"Asia/Taipei",
      "Perth"=>"Australia/Perth",
      "Irkutsk"=>"Asia/Irkutsk",
      "Ulaanbaatar"=>"Asia/Ulaanbaatar",
      "Seoul"=>"Asia/Seoul",
      "Osaka"=>"Asia/Tokyo",
      "Sapporo"=>"Asia/Tokyo",
      "Tokyo"=>"Asia/Tokyo",
      "Yakutsk"=>"Asia/Yakutsk",
      "Darwin"=>"Australia/Darwin",
      "Adelaide"=>"Australia/Adelaide",
      "Canberra"=>"Australia/Melbourne",
      "Melbourne"=>"Australia/Melbourne",
      "Sydney"=>"Australia/Sydney",
      "Brisbane"=>"Australia/Brisbane",
      "Hobart"=>"Australia/Hobart",
      "Vladivostok"=>"Asia/Vladivostok",
      "Guam"=>"Pacific/Guam",
      "Port Moresby"=>"Pacific/Port_Moresby",
      "Magadan"=>"Asia/Magadan",
      "Srednekolymsk"=>"Asia/Srednekolymsk",
      "Solomon Is."=>"Pacific/Guadalcanal",
      "New Caledonia"=>"Pacific/Noumea",
      "Fiji"=>"Pacific/Fiji",
      "Kamchatka"=>"Asia/Kamchatka",
      "Marshall Is."=>"Pacific/Majuro",
      "Auckland"=>"Pacific/Auckland",
      "Wellington"=>"Pacific/Auckland",
      "Nuku'alofa"=>"Pacific/Tongatapu",
      "Tokelau Is."=>"Pacific/Fakaofo",
      "Chatham Is."=>"Pacific/Chatham",
      "Samoa"=>"Pacific/Apia"
    }

    native_timezones["PST"] = "America/Los_Angeles"
    native_timezones["MST"] = "America/Denver"
    native_timezones["CST"] = "America/Chicago"
    native_timezones["EST"] = "America/New_York"

    Time.zone = native_timezones[time_zone]
    Time.at(unix_time).strftime("%Y-%m-%d %I:%M:%S %p")
  end
end
