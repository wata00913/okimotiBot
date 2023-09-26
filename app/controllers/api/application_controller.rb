# frozen_string_literal: true

require 'slack_client'

class Api::ApplicationController < ActionController::API
  def slack_client
    @slack_client ||= SlackClient.new
  end

  private

  def write_log(e)
    Rails.logger.error e.full_message.chomp
  end
end
