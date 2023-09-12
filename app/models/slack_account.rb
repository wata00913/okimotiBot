# frozen_string_literal: true

class SlackAccount < ApplicationRecord
  has_many :channel_members, dependent: :destroy
  has_many :channels, through: :channel_members, source: :slack_channel

  validates :account_id, presence: true, uniqueness: true
  validates :name, presence: true

  class << self
    def fetch_by_api_and_create!(account_id)
      account_response = SlackClient.new.fetch_account(account_id)
      SlackAccount.find_or_create_by!(account_id: account_response['id']) do |account|
        account.name = account_response['real_name']
        account.image_url = account_response['profile']['image_original']
      end
    end
  end
end
