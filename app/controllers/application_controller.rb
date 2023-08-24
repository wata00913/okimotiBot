# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?


  protected

  def after_sign_in_path_for(resource)
    messages_path
  end

  def after_sign_up_path_for(resource)
    messages_path
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  private

  def require_sign_in
    redirect_to new_user_session_path, alert: 'ログインしてください。' unless user_signed_in?
  end
end
