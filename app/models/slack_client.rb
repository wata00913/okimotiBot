# frozen_string_literal: true

class SlackClient
  def initialize
    @client = Slack::Web::Client.new
  end

  def fetch_channels
    @client.conversations_list['channels']
  end

  def fetch_member_ids_in(channel_id)
    @client.conversations_members(channel: channel_id)['members']
  end

  def fetch_account(account_id)
    @client.users_info(user: account_id)['user']
  end
end
