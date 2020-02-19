# controlers the scheduling of messages
class ScheduleController < ApplicationController

  def create
    bot_slack_client.chat_scheduleMessage(channel: params["channel_id"], text: params["text"], post_at: params["post_at"])
    render json: {"status": "Successful message schedule"}, status: 200
  end
end
