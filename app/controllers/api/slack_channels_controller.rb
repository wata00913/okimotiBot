# frozen_string_literal: true

class Api::SlackChannelsController < Api::ApplicationController
  include SlackApiErrorHandler

  def index
    channels_response = slack_client.fetch_channels
    SlackChannel.update_channels(channels_response)

    @updated_at = Time.zone.now
  end
end
