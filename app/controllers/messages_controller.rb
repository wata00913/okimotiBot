# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :require_sign_in

  def index
    ids = current_user.observed_members.pluck(:channel_member_id)
    @messages = Message.includes(:sentiment_score, channel_member: %i[slack_channel slack_account])
                       .where(channel_member_id: ids)
                       .order(slack_timestamp: :desc)
                       .page(params[:page])

    set_search_message
  end

  private

  def set_search_message
    search_params = params[:message]
    return unless search_params

    @messages = @messages.public_send("best_#{search_params[:best_emotion]}") unless search_params[:best_emotion].blank?
  end
end
