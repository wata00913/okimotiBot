# frozen_string_literal: true

require 'active_support/concern'

module SlackApiOperatable
  extend ActiveSupport::Concern

  def operate_slack_api
    @client ||= Slack::Web::Client.new
    begin
      @client.auth_test
      yield @client
      true
    rescue Slack::Web::Api::Errors::NotAuthed => e
      Rails.logger.error e.full_message.chomp
      false
    end
  end
end
