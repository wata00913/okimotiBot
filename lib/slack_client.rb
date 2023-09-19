# frozen_string_literal: true

class SlackClient
  def initialize
    @client = Slack::Web::Client.new
  end

  def fetch_channels
    @client.conversations_list['channels']
  end

  def fetch_channel_members(channel_id)
    member_ids_response = @client.conversations_members(channel: channel_id)['members']
    member_ids_response.map { |id| fetch_account(id) }
  end

  def fetch_channel_members_messages(channel_id, member_ids)
    messages_response = @client.conversations_history(channel: channel_id)
    messages_response['messages'].filter do |message_response|
      message_response['type'] == 'message' \
        && message_response['subtype'].nil? \
        && member_ids.include?(message_response['user'])
    end
  end

  def fetch_member_ids(channel_id)
    @client.conversations_members(channel: channel_id)['members']
  end

  def fetch_account(account_id)
    @client.users_info(user: account_id)['user']
  end
end
