# frozen_string_literal: true

class SlackChannel < ApplicationRecord
  include Discard::Model

  has_many :channel_members, dependent: :destroy
  has_many :accounts, through: :channel_members, source: :slack_account

  validates :channel_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  default_scope -> { kept }

  scope :will_deleted, ->(current_channel_ids) { where.not(channel_id: current_channel_ids) }

  after_discard do
    channel_members.discard_all
  end

  class << self
    def create_channels(channels_response)
      channels_response.each do |channel_response|
        create_channel(channel_response)
      end
    end

    def create_channel(channel_response)
      channel_id = channel_response['id']
      name = channel_response['name']

      find_or_create_by!(channel_id:) do |channel|
        channel.name = name
      end
    end
  end

  def create_members(members_response)
    members_response.map do |attr|
      member = SlackAccount.create_account(attr)
      accounts << member unless accounts.exists?(member.id)
    end
  end
end
