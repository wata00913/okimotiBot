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
end
