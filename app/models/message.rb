# frozen_string_literal: true

class Message < ApplicationRecord
  validates :channel_member_id, :slack_timestamp, :original_message,
            presence: true
end
