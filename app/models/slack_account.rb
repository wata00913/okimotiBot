# frozen_string_literal: true

class SlackAccount < ApplicationRecord
  validates :account_id, presence: true, uniqueness: true
  validates :name, presence: true
end
