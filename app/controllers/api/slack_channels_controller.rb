# frozen_string_literal: true

class Api::SlackChannelsController < ActionController::API
  before_action :set_slack_client, only: [:update]

  def index
    @slack_client.operate_slack_api do |slack_client|
      channels_response = slack_client.conversations_list['channels']

      channels_response.each do |channel_response|
        SlackChannel.find_or_create_by!(channel_id: channel_response['id']) do |channel|
          channel.name = channel_response['name']
        end
      end
    end
    @updated_at = Time.zone.now
  end

  private

  def set_slack_client
    @slack_client = SlackClient.new
  end
end
