# frozen_string_literal: true

class Message < ApplicationRecord
  MAX_ANALYSES = 5

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
  scope :channel_messages, ->(channel) { where(channel_member_id: channel.channel_member_ids) }
  scope :analyzed, -> { joins(:sentiment_score) }
  scope :unanalyzed, -> { left_outer_joins(:sentiment_score).where(sentiment_score: { id: nil }) }
  scope :analysis_target, -> { unanalyzed.order(slack_timestamp: :desc).take(MAX_ANALYSES) }

  class << self
    def latest_slack_timestamp(messages = nil)
      messages.nil? ? maximum(:slack_timestamp) : messages.maximum(:slack_timestamp)
    end

    def build_messages(messages)
      messages.map { |m| m.attributes.symbolize_keys }
    end

    def create_sentiment_scores(messages_response)
      messages_response['success'].each do |message_response|
        message = find(message_response['id'])
        message.create_sentiment_score!(message_response.slice('positive', 'negative', 'neutral', 'mixed'))
      end
    end
  end

  def escape_original_message
    Slack::Messages::Formatting.unescape(original_message)
  end
end
