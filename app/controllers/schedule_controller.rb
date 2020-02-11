class ScheduleController < ApplicationController
  def index
  end

  def create
    # if params["workspace_name"] && params["channel_name"]
    #   byebug
    #   workspace = Workspace.find_by(name: params["workspace_name"])
    #   channel = workspace.channels.find{ |channel| channel.name == params["channel_name"] }
    # end

    Dotenv.load('.env')
    client = Slack::Web::Client.new(token: ENV['BOT_USER_OAUTH_ACCESS_TOKEN'])

    byebug

    client.chat_scheduleMessage(channel: params["channel_id"], text: params["text"], post_at: params["post_at"])
  end

  def show
  end
end
