# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :observed_members, dependent: :destroy
  has_many :channel_members, through: :observed_members
  has_many :observed_channels, -> { distinct }, through: :channel_members, source: :slack_channel

  accepts_nested_attributes_for :observed_members, allow_destroy: true

  validates :name, presence: true, length: { maximum: 15 }
  validates :email, length: { maximum: 254 }

  def build_observed_members
    observed_members.includes(channel_member: %i[slack_channel slack_account])
      .inject({}) do |result, observed_member|
        channel = observed_member.slack_channel
        result[channel] ||= []
        result[channel] << observed_member
        result
      end
  end

  def observed_members_messages(observed_member_ids = nil)
    ids = if observed_member_ids.nil?
            channel_member_ids
          else
            observed_members.where(id: observed_member_ids).pluck(:channel_member_id)
          end
    Message.all.where(channel_member_id: ids)
  end
end
