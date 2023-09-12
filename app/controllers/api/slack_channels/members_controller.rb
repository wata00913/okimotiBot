# frozen_string_literal: true

class Api::SlackChannels::MembersController < ActionController::API
  def index
    channel_id = params[:slack_channel_id]
    @channel = SlackChannel.find_by(channel_id:)
    @channel.fetch_members_and_create!
  end
end
