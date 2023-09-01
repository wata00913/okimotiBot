# frozen_string_literal: true

class SlackAccount < ApplicationRecord
  has_many :channel_members, dependent: :destroy
  has_many :channels, through: :channel_members, source: :slack_channel

  validates :account_id, presence: true, uniqueness: true
  validates :name, presence: true
end
