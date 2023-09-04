# frozen_string_literal: true

class Api::ObservedMembersController < ActionController::API
  def index
    client = Slack::Web::Client.new
    @channel = SlackChannel.find_by(channel_id: params[:channel_id])

    channel_member_ids = client.conversations_members(channel: params[:channel_id])['members']
    channel_member_ids.map do |id|
      user_info = client.users_info(user: id)['user']
      member = SlackAccount.find_or_create_by!(account_id: user_info['id']) do |account|
        account.name = user_info['real_name']
        account.image_url = user_info['profile']['image_original']
      end

      @channel.accounts << member unless @channel.accounts.exists?(member.id)
    end
  end
end
