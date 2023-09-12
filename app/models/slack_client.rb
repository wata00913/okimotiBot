# frozen_string_literal: true

class SlackClient
  def initialize
    @client = Slack::Web::Client.new
  end

  def operate_slack_api
    begin
      @client.auth_test
      yield @client
      true
    rescue Slack::Web::Api::Errors::NotAuthed => e
      Rails.logger.error e.full_message.chomp
      false
    end
  end

  def fetch_channels
    @client.conversations_list['channels']
  end

  def fetch_members_in(channel_id)
    @client.conversations_members(channel: channel_id)['members']
  end

  def fetch_account(account_id)
    @client.users_info(user: account_id)['user']
  end
end
