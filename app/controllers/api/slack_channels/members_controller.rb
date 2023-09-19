# frozen_string_literal: true

class Api::SlackChannels::MembersController < Api::ApplicationController
  include SlackApiErrorHandler

  def index
    channel_id = params[:slack_channel_id]

    members_response = slack_client.fetch_channel_members(channel_id)

    @channel = SlackChannel.find_by(channel_id:)
    @channel.create_members(members_response)
  end
end
