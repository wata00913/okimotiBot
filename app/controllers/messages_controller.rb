class MessagesController < ApplicationController
  before_action :require_sign_in

  def index
    ids = current_user.observed_members.pluck(:channel_member_id)
    @messages = Message.where(channel_member_id: ids).order(slack_timestamp: :desc)
  end
end
