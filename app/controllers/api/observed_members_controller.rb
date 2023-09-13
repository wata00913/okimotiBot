# frozen_string_literal: true

class Api::ObservedMembersController < Api::ApplicationController
  include SlackApiErrorHandler

  def index
    @channel_to_observed_members = current_user.channel_to_observed_members
  end
end
