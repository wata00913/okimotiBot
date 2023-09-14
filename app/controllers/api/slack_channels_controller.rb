# frozen_string_literal: true

class Api::SlackChannelsController < Api::ApplicationController
  include SlackApiErrorHandler

  def index
    channels_response = slack_client.fetch_channels
    SlackChannel.find_or_create_by_attrs!(channels_response, channel_id_key: :id)
    @updated_at = Time.zone.now
  end
end
