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
end
