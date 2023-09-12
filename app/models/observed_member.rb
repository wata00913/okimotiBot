# frozen_string_literal: true

class ObservedMember < ApplicationRecord
  belongs_to :user
  belongs_to :channel_member
  has_many :messages, through: :channel_member

  validates :user_id, presence: true, uniqueness: { scope: :channel_member_id }
  validates :channel_member_id, presence: true

  delegate :slack_channel, to: :channel_member
  delegate :slack_account, to: :channel_member
end
