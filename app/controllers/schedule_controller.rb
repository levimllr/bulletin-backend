class ScheduleController < ApplicationController
  def index
  end

  def create
    bot_slack_client.chat_scheduleMessage(channel: params["channel_id"], text: params["text"], post_at: params["post_at"])
    render json: {"status": "Successful message schedule"}, status: 200
  end

  def show
  end
end
