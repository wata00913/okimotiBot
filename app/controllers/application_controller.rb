# frozen_string_literal: true

require 'slack_client'

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(_resource)
    messages_path
  end

  def after_sign_up_path_for(_resource)
    messages_path
  end

  def after_sign_out_path_for(_resource)
    new_user_session_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def require_sign_in
    redirect_to new_user_session_path, alert: 'ログインしてください。' unless user_signed_in?
  end

  def slack_client
    @slack_client ||= SlackClient.new
  end
end
