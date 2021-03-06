# this controller handles the events of being 
# verified by the Slack app dashboard and added to a channel
class EventsController < ApplicationController
  def index
  end

  def create
    
    case params['type']
      when 'url_verification'
        # When we receive a `url_verification` event, we need to
        # return the same `challenge` value sent to us from Slack
        # to confirm our server's authenticity.
        params['challenge']

      when 'event_callback'
        # Get the Team ID and event data from the request object
        team_id = params['team_id']
        event_data = params['event']

        # Events have a "type" attribute included in their payload, allowing you to handle different
        # event payloads as needed.
        case event_data['type']
            when 'url_verification'
                # When we receive a `url_verification` event, we need to
                # return the same `challenge` value sent to us from Slack
                # to confirm our server's authenticity.
                params['challenge']
            
            when 'member_joined_channel'
                # Event handler for when a user joins a team
                # Events.user_join(team_id, event_data)

                bot_id = event_data['user']
                channel_id = event_data['channel']
                workspace = Workspace.find_by(bot_id: bot_id)

                # check to see if the member which joined a channel is this app's bot
                if Workspace.bot_id?(bot_id)
                  Channel.create(channel_id: channel_id, workspace_id: workspace.id)
                  Dotenv.load('.env')
                  client = Slack::Web::Client.new(token: ENV['BOT_USER_OAUTH_ACCESS_TOKEN'])
                  puts "###############"
                  puts "##### BOT #####"
                  puts "###############"
                  intro_note = ":koko: Hello world!\n:u7533: This channel's ID is *#{channel_id}*.\n:sa: To set up your mass message schedule, make a copy of this Google sheet:\n#{@@sheet_link}"
                  notify_channel(intro_note, channel_id)

                else 
                  puts '---------------------'
                  puts '----- not a bot -----'
                  puts '---------------------'
                end
                
            else
                # In the event we receive an event we didn't expect, we'll log it and move on.
                puts "Unexpected event:\n"
                puts JSON.pretty_generate(params)
        end
    end

    # Return HTTP status code 200 so Slack knows we've received the event
    render json: params['challenge']
  end
end
