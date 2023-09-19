# frozen_string_literal: true

class Api::SlackChannelsController < Api::ApplicationController
  include SlackApiErrorHandler

  def index
    channels_response = slack_client.fetch_channels

    channel_ids = channels_response.map(&:id)
    SlackChannel.will_deleted(channel_ids).discard_all

    SlackChannel.create_channels(channels_response)
    @updated_at = Time.zone.now
  end
end
