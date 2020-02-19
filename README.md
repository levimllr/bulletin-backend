# 🗃 Bulletin - A Mass Message Scheduling Slack App

Bulletin is Slack app that leverages Google Sheets and this Rails server to schedule messages en masse.

## 🔩 Components

### 📑 Google Sheet & Script

#### 📊 Google Sheet

The Google Sheet database can be found [here](https://docs.google.com/spreadsheets/d/1FNN6pRAMpxZPdT4reFGSqo_2EPYo6W-X9wLFmuWbWYU/edit#gid=0). The purpose of this sheet is to store the messages that are intended to be scheduled, along with their target channel and time. These column headers are formatted **bold** and are required. The _italicized_ column headers are optional and for personal reference.

The Google Sheet is linked to a Google Script, which can be found by going to `Tools > Script Editor`. **Each copy made of this Google sheet will also make a copy of the Google Script.** All of these sheets will be able to talk to the Rails server. This feature may become a barrier to scaling.

To schedule messages en masse, a user goes to the `Schedule Slack Messages` menu in their Google sheet. From this menu, a user can either schedule all messages or delete all messages. "All messages" means any row greater than 2 with an entry.

#### 📝 Google Script

The Google Script is pre-ES6 JavaScript that leverages Google APIs to communicate with the Google Sheet and our Rails server. It serves to create a custom menu on the Google Sheet that that triggers functions for scheduling and deleting scheduled messages.

### 🚂 Rails Server

This repository contains the Rails server. It's job is to serve as a kind of glorified router, taking messages from the Google Sheet, adding the app's authorization token, and sending them on to the appropriate endpoint of the Slack API. **In the interest of privacy, the server database only stores channel and workplace informace, _not_ message contents.**

### 🕹 Slack App Dashboard

The Slack app dashboard provides configurations and credentials for our Rails server to interface with the Slack API. Among the items:

- Credentials (secret)
  - App ID
  - Bot User OAuth Access Token
  - Client ID
  - API Secret
  - Verification
  - Redirect URI
- Display Information
  - App name
  - Short description: "Schedule multiple messages at once."
  - App icon and background color
- Slash Commands
- OAuth and Permissions
  - Bot token scopes
    - channels:read
    - chat:write
    - commands
    - groups:history
    - groups:read
    - groups:write
    - users:write
  - User token scopes
    - chat:write
    - users:write
- Event Subscriptions
  - Request URL
  - Subscriptions to bot events
    - member_joined_channel
    - message.groups

## ⚒ Testing

When this app is in production, all app URLs should point to the Heroku domain (https://bulletin-slack-app.herokuapp.com/). When making changes and testing locally, all app URLs need to point to the local server. To allow external servers from Google and Slack to communicate with the local server, a tool must be used to create a tunnel to the Rails local development server.

Use [ngrok](https://dashboard.ngrok.com/get-started) to make a local server public-facing. `ngrok http PORTNUMBER` is the command you'll want, which for this Rail API will look like `ngrok http 3001`. **To use ngrok with this Rails server, check the following settings:**

1. In `/config/environments/development.rb`, ensure that line 54 (or thereabouts) has the correst ngrok host alias, such as `config.hosts << "1eec2ac2.ngrok.io"`. Note that ever time the command in the previous paragraph is run, a new ngrok alias is made. To avoid having to change it, you can simply leave the ngrok tunnel running (which will happen unless you Ctrl+C kill it). 
2. In the Slack app dashboard, make sure the Slash Commands Request URL refers to the ngrok tunnel (e.g. https://1eec2ac2.ngrok.io/commands).
3. In the Slack app dashboard under OAuth & Permissions, make sure the Redirect URL refers to the ngrok tunnel (e.g. https://1eec2ac2.ngrok.io/finish_auth).
4. In the Slack app dashboard under Event Subscriptions, make sure the Request URL refers to the ngrok tunnel (e.g. https://1eec2ac2.ngrok.io/events).
5. **When finished working locally, make sure to change all the URLs in the Slack app dashboard back to the Heroku domain).**

## 📚 Resources

- Time
  - [Invalid Time.zone timezone](https://stackoverflow.com/questions/31565999/invalid-timezone)
