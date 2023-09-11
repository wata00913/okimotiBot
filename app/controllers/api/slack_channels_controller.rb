# frozen_string_literal: true

class Api::SlackChannelsController < ActionController::API
  def index
    SlackChannel.fetch_by_api_and_create!
    @updated_at = Time.zone.now
  end
end
