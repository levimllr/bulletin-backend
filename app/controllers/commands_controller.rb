# this controller handles all slash commands made from Slack
# slash commands must also be configured in the Slack app dashboard
class CommandsController < ApplicationController

  # since a post request is made of /commands, we call the create controller action
  def create

    # only recognize command if it starts with /bulletin
    if params["command"] == "/bulletin"

      # standard info to harvest across almost all commands (except for option and modifer)
      channel_id = params["channel_id"]
      user_id = params["user_id"]
      channel_name = params["channel_name"]
      full_command = params["text"].split(" ")
      command = full_command[0]
      option = full_command[1]
      modifier = full_command[2]

      # handle different commands, such as '/bulletin intro' or '/bulletin delete all'
      case command
      when "intro"
        intro_note = ":koko: Hello world!\n:u7533: This channel's ID is *#{channel_id}*.\n:sa: To set up your mass message schedule, make a copy of this Google sheet:\n#{@@sheet_link}"
        notify_user(intro_note, channel_id, user_id)

      when "channel"
        channel_info_note = ":u7533: #{channel_name}'s channel ID is *#{channel_id}*."
        notify_user(channel_info_note, channel_id, user_id)

      when "sheet"
        sheet_info_note = ":sa: To set up your mass message schedule, make a copy of this Google sheet:\n#{@@sheet_link}"
        notify_user(sheet_info_note, channel_id, user_id)

      when "schedule"
        messages = scheduled_messages(channel_id)
        full_schedule_note = format_schedule_message(messages, channel_name, channel_id)
        notify_user(full_schedule_note, channel_id, user_id)

      when "delete"
        case option
        when "all"
          messages = scheduled_messages(channel_id)
          begin
            delete_channel_messages(messages, channel_id)
          rescue => exception
            delete_all_error_note = ":u6e80: *ERROR DELETING ALL MESSAGES* ```#{exception}```"
            notify_user(delete_all_error_note, channel_id, user_id)
          else
            delete_all_success_note = ":congratulations: *All #{messages.length} scheduled messages were successfully deleted!*"
            notify_user(delete_all_success_note, channel_id, user_id)
          end
        when "from", "to"
          begin
            date = Date.parse(modifier).to_time.to_i
            if option == "from"
              range = scheduled_messages(channel_id).select{|msg| msg.post_at >= date}
              preps = "_on and after_"
            elsif option == "to"
              range = scheduled_messages(channel_id).select{|msg| msg.post_at < date}
              preps = "_up to_"
            end
            delete_channel_messages(range, channel_id)
            notification = ":congratulations: All *#{range.length}* scheduled messages #{preps} *#{modifier}* were successfully deleted!"
            notify_user(notification, channel_id, user_id)
          rescue => exception
            notification = ":u6e80: *ERROR DELETING MESSAGES WITH DATE #{date}* ```#{exception}```"
            notify_user(notification, channel_id, user_id)
          end
        
        when nil
          invalid_delete_note = ":u7981: To delete messages, enter either `/bulletin delete MESSAGE_ID`, `/bulletin delete to|from DATE`, or `/bulletin delete all`."
          notify_user(invalid_delete_note, channel_id, user_id)

        else
          begin
            delete_message(option, channel_id)

          rescue => exception
            invalid_id_note = ":u6e80: *ERROR: NO MESSAGE WITH THE ID #{option} FOUND!* ```#{exception}```"
            notify_user(invalid_id_note, channel_id, user_id)

          else
            valid_delete_note = ":u7a7a: The message with the id *#{option}* was successfully deleted!"
            notify_user(valid_delete_note, channel_id, user_id)

          end
        end

      else
        invalid_command_note = ":u7981: Invalid command! Type `/bulletin` or click on my icon see options."
        notify_user(invalid_command_note, channel_id, user_id)

      end 
    end
  end

  private

  # helper method for formating the schedule message
  def format_schedule_message(messages, channel_name, channel_id)
    if messages.length > 0
      schedule_string_prefix = [
        ":u6307: There are *#{messages.length} messages* scheduled for *#{channel_name}* channel *#{channel_id}*.",
        ":u6708: Messages are scheduled between *#{format_unix_to_normal_time(messages.first.post_at)}* and *#{format_unix_to_normal_time(messages.last.post_at)}*:",
        "```",
        " ## |    Local date, time    | Message ID",
        "----|------------------------|-----------"
      ]
      schedule_string = messages.map.with_index do |msg, idx|
        " #{idx + 1} | #{Time.at(msg.post_at).strftime("%Y-%m-%d %I:%M:%S %p")} | #{msg.id}"
      end

      full_schedule_note = schedule_string_prefix.push(schedule_string).push("```").join("\n")
    
    else
      full_schedule_note = ":u6307: There are *_no_ messages* scheduled for channel *#{channel_id}*."
    
    end
  end

  # gets all scheduled messages for a channel
  def scheduled_messages(channel_id)
    bot_slack_client.chat_scheduledMessages_list(
      channel: channel_id,
    )[:scheduled_messages].sort_by{ |msg| msg.post_at }
  end

  # deletes a message scheduled for a channel
  def delete_message(msg_id, channel_id)
    bot_slack_client.chat_deleteScheduledMessage(
      channel: channel_id,
      scheduled_message_id: msg_id
    )
  end

  # deletes ALL messages scheduled for achannel
  def delete_channel_messages(messages, channel_id)
    message_ids = messages.map{ |msg| msg.id }
    message_ids.each do |id|
      delete_message(id, channel_id)
    end
  end
end
