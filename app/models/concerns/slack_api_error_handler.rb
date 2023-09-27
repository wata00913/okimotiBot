# frozen_string_literal: true

require 'active_support/concern'

module SlackApiErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from Slack::Web::Api::Errors::NotAuthed, with: :not_authed
    rescue_from Slack::Web::Api::Errors::InvalidAuth, with: :invalid_auth
    rescue_from Slack::Web::Api::Errors::ChannelNotFound, with: :channel_not_found
    rescue_from Slack::Web::Api::Errors::UserNotFound, with: :account_not_found
  end

  private

  def not_authed(e)
    write_log(e)
    render json: { error: 'SlackAPIの認証に失敗しました。' }, status: :unauthorized
  end

  def invalid_auth(e)
    write_log(e)
    render json: { error: 'SlackAPIの認証に失敗しました。' }, status: :unauthorized
  end

  def channel_not_found(e)
    write_log(e)
    render json: { error: 'チャンネルが見つかりませんでした。' }, status: :bad_request
  end

  def account_not_found(e)
    write_log(e)
    render json: { error: 'Slackユーザーが見つかりませんでした。' }, status: :bad_request
  end
end
