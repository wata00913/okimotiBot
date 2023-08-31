# frozen_string_literal: true

class Api::ObservedMembersController < ActionController::API
  def index
    client = Slack::Web::Client.new
    channel_member_ids = client.conversations_members(channel: params[:channel_id])['members']

    @channel_members_info = channel_member_ids.map do |id|
      client.users_info(user: id)['user']
    end
  end
end
