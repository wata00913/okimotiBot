# frozen_string_literal: true

require 'slack_client'

class Api::ApplicationController < ActionController::API
  def slack_client
    @slack_client ||= SlackClient.new
  end
end
