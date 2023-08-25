# frozen_string_literal: true

class ChannelMember < ApplicationRecord
  belongs_to :slack_channel
  belongs_to :slack_account
end
