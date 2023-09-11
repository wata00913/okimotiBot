# frozen_string_literal: true

class Message < ApplicationRecord
  belongs_to :channel_member
  has_one :sentiment_score, dependent: :destroy

  validates :channel_member_id, :slack_timestamp, :original_message,
            presence: true

  scope :best_positive, lambda {
                          joins(:sentiment_score)
                            .where('sentiment_scores.positive > sentiment_scores.negative
                                    and sentiment_scores.positive > sentiment_scores.neutral') }
  scope :best_negative, lambda {
                          joins(:sentiment_score)
                            .where('sentiment_scores.negative > sentiment_scores.positive
                                   and sentiment_scores.negative > sentiment_scores.neutral') }
  scope :best_neutral, lambda {
                         joins(:sentiment_score)
                           .where('sentiment_scores.neutral > sentiment_scores.negative
                                   and sentiment_scores.neutral > sentiment_scores.positive') }
end
