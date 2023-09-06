# frozen_string_literal: true

class Api::SlackChannels::MembersController < ActionController::API
  def index
    client = Slack::Web::Client.new
    channel_id = params[:slack_channel_id]
    @channel = SlackChannel.find_by(channel_id:)

    channel_member_ids = client.conversations_members(channel: channel_id)['members']
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
