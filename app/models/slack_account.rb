# frozen_string_literal: true

class SlackAccount < ApplicationRecord
  has_many :channel_members, dependent: :destroy
  has_many :channels, through: :channel_members, source: :slack_channel

  validates :account_id, presence: true, uniqueness: true
  validates :name, presence: true

  class << self
    def find_or_create_by_attr!(attr, account_id_key: :account_id, name_key: :name, image_url_key: :image_url)
      account_id = find_attr_value(attr, account_id_key)
      name = find_attr_value(attr, name_key)
      image_url = find_attr_value(attr, image_url_key)

      find_or_create_by!(account_id:) do |account|
        account.name = name
        account.image_url = image_url
      end
    end
  end
end
