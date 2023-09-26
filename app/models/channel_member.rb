# frozen_string_literal: true

class ChannelMember < ApplicationRecord
  include Discard::Model

  belongs_to :slack_channel
  belongs_to :slack_account

  has_many :messages, dependent: :destroy

  has_many :observed_members, dependent: :destroy
  has_many :observers, through: :observed_members, source: :user

  validates :slack_channel_id, presence: true, uniqueness: { scope: :slack_account_id }
  validates :slack_account_id, presence: true

  default_scope -> { kept }

  class << self
    def create_messages(messages_response, channel)
      messages_response.each do |message_response|
        channel_member = channel.channel_member_by_account_id(message_response['user'])
        slack_timestamp = message_response['ts'].to_f
        original_message = message_response['text']

        Message.create!({ channel_member_id: channel_member.id, slack_timestamp:, original_message: })
      end
    end
  end
end
