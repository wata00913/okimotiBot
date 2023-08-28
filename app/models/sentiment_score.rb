# frozen_string_literal: true

class SentimentScore < ApplicationRecord
  belongs_to :message

  validates :message_id, :positive, :negative, :neutral, :mixed,
            presence: true
end
