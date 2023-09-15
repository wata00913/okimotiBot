# frozen_string_literal: true

class ObservedMember < ApplicationRecord
  belongs_to :user
  belongs_to :channel_member
  has_many :messages, through: :channel_member

  validates :user_id, presence: true, uniqueness: { scope: :channel_member_id }
  validates :channel_member_id, presence: true

  delegate :slack_channel, to: :channel_member
  delegate :slack_account, to: :channel_member

  class << self
    def convert_params_to_attributes(user_id, observed_member_params)
      observed_member_params.map do |observed_member_param|
        observed_member_param['members'].map do |observed_member|
          attr = { 'user_id' => user_id,
                   'channel_member_id' => observed_member['channel_member_id'] }
          attr['id'] = observed_member['id'] if observed_member.key?('id')
          attr['_destroy'] = true unless observed_member['observe']
          attr
        end
      end.flatten
    end
  end
end
