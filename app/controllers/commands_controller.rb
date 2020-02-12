class CommandsController < ApplicationController
  def create
    sheet_link = "https://docs.google.com/spreadsheets/d/1FNN6pRAMpxZPdT4reFGSqo_2EPYo6W-X9wLFmuWbWYU/edit?usp=sharing"

    if params["command"] == "/bulletin"
      channel_id = params["channel_id"]
      case params["text"]
      when "intro"
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":u55b6: Hello world!\n:id: This channel's ID is *#{channel_id}*.\n:hash:To set up your mass message schedule, make a copy of this Google sheet:\n#{sheet_link}"
        )
      when "channel"
        channel_name = params["channel_name"]
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":id: #{channel_name}'s channel ID is *#{channel_id}*."
        )
      when "sheet"
        channel_name = params["channel_name"]
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":hash: To set up your mass message schedule, make a copy of this Google sheet:\n#{sheet_link}"
        )
      else
        bot_slack_client.chat_postMessage(
          channel: channel_id,
          text: ":sos: Invalid command! Type `/bulletin` or click on my icon see options." 
        )
      end 
    end
  end
end
