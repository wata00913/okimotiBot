# frozen_string_literal: true

class Api::SlackChannelsController < ActionController::API
  include SlackApiErrorHandler

  def index
    slack_client = SlackClient.new
    channels_response = slack_client.fetch_channels

    channels_response.each do |channel_response|
      SlackChannel.find_or_create_by_attr(channel_response, channel_id_key: :id)
    end
    @updated_at = Time.zone.now
  end
end
