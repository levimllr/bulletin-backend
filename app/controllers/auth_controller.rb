class AuthController < ApplicationController
  def begin
    # set OAuth scope of bot
    # for this demo, we're just using `bot` as it has access to all we need
    # see https://api.slack.com/docs/oauth-scopes for more info.
    bot_scope = 'bot'

    add_to_slack_button = "
      <a href=\"https://slack.com/oauth/authorize?scope=#{bot_scope}&client_id=#{slack_config[:slack_client_id]}&redirect_uri=#{slack_config[:redirect_uri]}\">
        <img alt=\"Add to Slack\" height=\"40\" width=\"139\" src=\"https://platform.slack-edge.com/img/add_to_slack.png\"/>
      </a>"

    render html: add_to_slack_button.html_safe
  end

  def finish
    client = Slack::Web::Client.new

    # OATH STEP 3: Success or Failure
    begin
        response = client.oauth_access({
                client_id: ENV['SLACK_CLIENT_ID'],
                client_secret: ENV['SLACK_API_SECRET'],
                redirect_uri: ENV['SLACK_REDIRECT_URI'],
                code: params[:code] # this is the OAUTH code mentioned above
        })

        # SUCCESS: store tokens and create Slack client to use with Event Handlers
        # Tokens used for accessing web API, but process also creates team's bot user
        # and authorizes the app to access the team's event
        team_id = response['team_id']
        teams = {}
        teams[team_id] = {
            user_access_token: response['access_token'],
            bot_user_id: response['bot']['bot_user_id'],
            bot_access_token: response['bot']['bot_access_token']
        }

        teams[team_id]['client'] = create_slack_client(response['bot']['bot_access_token'])
        
        Workplace.create(
          team_id: team_id,
          team_name: response['team_name'],
          bot_id: response['bot']['bot_user_id']
        )

        byebug

        render body: "OAuth succeeded!"

    rescue Slack::Web::Api::Error => exception
        # FAILURE
        # let user know something went wrong
        # status 403
        byebug
        render body: "Auth failed! Reason: #{exception.message}<br/>#{add_to_slack_button}"
        
    end
  end
end
