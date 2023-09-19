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
    channel_members.destroy_all
  end

  class << self
    def create_channels(channels_response)
      channels_response.each do |channel_response|
        find_or_create_by_attr!(channel_response, channel_id_key: :id)
      end
    end

    def find_or_create_by_attr!(attr, channel_id_key: :channel_id, name_key: :name)
      channel_id = find_attr_value(attr, channel_id_key)
      name = find_attr_value(attr, name_key)

      find_or_create_by!(channel_id:) do |channel|
        channel.name = name
      end
    end
  end

  def create_members(members_response)
    find_or_create_members_by_attrs!(members_response, account_id_key: :id, name_key: :real_name, image_url_key: %i[profile image_original])
  end

  def find_or_create_members_by_attrs!(attrs, account_id_key: :account_id, name_key: :name, image_url_key: :image_url)
    attrs.map do |attr|
      member = SlackAccount.find_or_create_by_attr!(attr, account_id_key:, name_key:, image_url_key:)
      accounts << member unless accounts.exists?(member.id)
    end
  end
end
