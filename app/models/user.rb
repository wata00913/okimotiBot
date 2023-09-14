# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :observed_members, dependent: :destroy
  has_many :channel_members, through: :observed_members

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
end
