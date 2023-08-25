# frozen_string_literal: true

class SlackChannel < ApplicationRecord
  validates :channel_id, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true
end
