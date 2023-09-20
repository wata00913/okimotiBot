# frozen_string_literal: true

class SlackAccount < ApplicationRecord
  has_many :channel_members, dependent: :destroy
  has_many :channels, through: :channel_members, source: :slack_channel

  validates :account_id, presence: true, uniqueness: true
  validates :name, presence: true

  class << self
    def create_account(account_response)
      account_id = account_response['id']
      name = account_response['real_name']
      image_url = account_response['profile']['image_original']

      find_or_create_by!(account_id:) do |account|
        account.name = name
        account.image_url = image_url
      end
    end
  end
end
