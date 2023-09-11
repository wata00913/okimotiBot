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

    set_message_during(Time.zone.parse(search_params['start_at']), Time.zone.parse(search_params['end_at']))
  end

  def set_message_during(start_at, end_at)
    return if start_at.nil? && end_at.nil?

    # nilの場合はそのままnilとして扱う
    start_timestamp = start_at&.to_f
    end_timestamp = end_at&.to_f
    @messages = @messages.where(slack_timestamp: start_timestamp..end_timestamp)
  end
end
