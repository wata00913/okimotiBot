# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :require_sign_in
  before_action :set_search_params, :set_selected_observed_member_ids_param, only: :index

  def index
    set_messages

    if params[:message]
      set_search_messages
    else
      @messages = @messages.merge(current_user.observed_members_messages)
    end
  end

  def reload_messages
    collect_messages
    set_messages

    @messages = @messages.merge(current_user.observed_members_messages)

    render :index
  end

  private

  def set_search_params
    @search_params = params[:message]
  end

  def set_search_messages
    set_search_messages_where_best_emotion(@search_params[:best_emotion])
    set_search_messages_where_observed_members(@search_params[:selected_observed_member_ids])
    set_search_messages_during(Time.zone.parse(@search_params[:start_at]), Time.zone.parse(@search_params[:end_at]))
  end

  def set_search_messages_where_best_emotion(type)
    @messages = @messages.public_send("best_#{type}") if type.present?
  end

  def set_search_messages_where_observed_members(observed_member_ids)
    @messages = @messages.merge(current_user.observed_members_messages(observed_member_ids))
  end

  def set_search_messages_during(start_at, end_at)
    return if start_at.nil? && end_at.nil?

    # nilの場合はそのままnilとして扱う
    start_timestamp = start_at&.to_f
    end_timestamp = end_at&.to_f
    @messages = @messages.where(slack_timestamp: start_timestamp..end_timestamp)
  end

  def set_selected_observed_member_ids_param
    return unless @search_params

    @search_params[:selected_observed_member_ids] = JSON.parse(params[:selected_observed_member_ids]).map(&:to_i)
  end

  def set_messages
    @messages = Message.all
                       .includes(:sentiment_score, channel_member: %i[slack_channel slack_account])
                       .order(slack_timestamp: :desc)
                       .page(params[:page])
  end

  def collect_messages
    observed_members = current_user.build_observed_members

    observed_members.each do |channel, members|
      member_ids = members.map { |m| m.slack_account.account_id }
      from = Message.channel_messages(channel).latest_slack_timestamp
      messages_response = slack_client.fetch_channel_members_messages(channel.channel_id, member_ids, from:)

      ChannelMember.create_messages(messages_response, channel)
    end
  end
end
