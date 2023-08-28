# frozen_string_literal: true

class SentimentScore < ApplicationRecord
  validates :message_id, :positive, :negative, :neutral, :mixed,
            presence: true
end
