# frozen_string_literal: true

class ObservedMember < ApplicationRecord
  validates :user_id, presence: true, uniqueness: { scope: :channel_member_id }
  validates :channel_member_id, presence: true
end
