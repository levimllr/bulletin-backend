class EventsController < ApplicationController
  def index
  end

  def create
    # byebug
    
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
                if Workplace.bot_id?(bot_id)
                  client = Slack::Web::Client.new
                  puts  "######BOT######"
                  client.chat_postMessage(
                    channel: channel_id,
                    text: "Hello world! This channel's ID is #{channel_id}. \n 
                      To set up your mass message schedule, make a copy of this Google sheet: \n 
                      https://docs.google.com/spreadsheets/d/1FNN6pRAMpxZPdT4reFGSqo_2EPYo6W-X9wLFmuWbWYU/edit?usp=sharing"
                  )
                else 
                  puts '------not a bot------'
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
