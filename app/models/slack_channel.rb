# frozen_string_literal: true

class SlackChannel < ApplicationRecord
  has_many :channel_members, dependent: :destroy
  has_many :accounts, through: :channel_members, source: :slack_account

  validates :channel_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
