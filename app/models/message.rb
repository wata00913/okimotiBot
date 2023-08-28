# frozen_string_literal: true

class Message < ApplicationRecord
  has_one :sentiment_score, dependent: :destroy

  validates :channel_member_id, :slack_timestamp, :original_message,
            presence: true
end
