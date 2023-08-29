# frozen_string_literal: true

class SentimentScore < ApplicationRecord
  belongs_to :message

  validates :message_id, :positive, :negative, :neutral, :mixed,
            presence: true

  ICON_TYPE = {
    positive: '😄',
    negative: '😰',
    neutral: '😐'
  }.freeze

  def to_emotion
    scores = attributes.transform_keys(&:to_sym).slice(:positive, :negative, :neutral)
    max_type = scores.max_by { |_, v| v }[0]
    ICON_TYPE[max_type]
  end
end
