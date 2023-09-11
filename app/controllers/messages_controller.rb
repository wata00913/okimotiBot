# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :require_sign_in
  before_action :set_selected_observed_member_ids_param, only: :index

  def index
    @messages = Message.includes(:sentiment_score, channel_member: %i[slack_channel slack_account])
                       .order(slack_timestamp: :desc)
                       .page(params[:page])

    if params[:message]
      set_search_messages
    else
      channel_member_ids = current_user.observed_members.pluck(:channel_member_id)
      @messages = @messages.where(channel_member_id: channel_member_ids)
    end
  end

  private

  def set_search_messages
    search_params = params[:message]

    set_search_messages_where_best_emotion(search_params[:best_emotion])
    set_search_messages_where_observed_members(search_params[:selected_observed_member_ids])
    set_search_messages_during(Time.zone.parse(search_params[:start_at]), Time.zone.parse(search_params[:end_at]))
  end

  def set_search_messages_where_best_emotion(type)
    @messages = @messages.public_send("best_#{type}") if type.present?
  end

  def set_search_messages_where_observed_members(ids)
    return if ids.empty?

    channel_member_ids = current_user.observed_members.where(id: ids)
    @messages = @messages.where(channel_member_id: channel_member_ids)
  end

  def set_search_messages_during(start_at, end_at)
    return if start_at.nil? && end_at.nil?

    # nilの場合はそのままnilとして扱う
    start_timestamp = start_at&.to_f
    end_timestamp = end_at&.to_f
    @messages = @messages.where(slack_timestamp: start_timestamp..end_timestamp)
  end

  def set_selected_observed_member_ids_param
    search_params = params[:message]
    return unless search_params

    params[:message][:selected_observed_member_ids] = JSON.parse(params[:selected_observed_member_ids]).map(&:to_i)
  end
end
