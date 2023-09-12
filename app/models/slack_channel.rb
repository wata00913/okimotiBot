# frozen_string_literal: true

class SlackChannel < ApplicationRecord
  has_many :channel_members, dependent: :destroy
  has_many :accounts, through: :channel_members, source: :slack_account

  validates :channel_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  class << self
    def fetch_by_api_and_create!
      channels_response = SlackClient.new.fetch_channels

      channels_response.each do |channel_response|
        find_or_create_by!(channel_id: channel_response['id']) do |channel|
          channel.name = channel_response['name']
        end
      end
    end
  end

  def fetch_members_and_create!
    member_ids_response = SlackClient.new.fetch_member_ids_in(channel_id)
    member_ids_response.map do |account_id|
      member = SlackAccount.fetch_by_api_and_create!(account_id)
      accounts << member unless accounts.exists?(member.id)
    end
  end
end
