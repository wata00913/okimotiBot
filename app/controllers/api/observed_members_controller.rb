# frozen_string_literal: true

class Api::ObservedMembersController < Api::ApplicationController
  include SlackApiErrorHandler

  def index
    @observed_members = current_user.build_observed_members
  end
end
