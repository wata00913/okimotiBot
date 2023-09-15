# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  before_action :set_observed_members_attributes, only: [:update]

  def edit
    begin
      channels_response = slack_client.fetch_channels

      channel_ids = channels_response.map(&:id)
      SlackChannel.will_deleted(channel_ids).discard_all

      SlackChannel.find_or_create_by_attrs!(channels_response, channel_id_key: :id)
    rescue Slack::Web::Api::Errors::NotAuthed
      flash[:alert] = 'SlackAPIの認証に失敗しました。'
    rescue Slack::Web::Api::Errors::TimeoutError
      flash[:alert] = 'Slackチャンネルの取得に失敗しました。'
    end
    super
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: [
                                        :name,
                                        { observed_members_attributes: %i[id user_id channel_member_id _destroy] }
                                      ])
  end

  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      params.delete(:password)
      params.delete(:password_confirmation)
      params.delete(:current_password)

      resource.update_without_password(params)
    else
      resource.update_with_password(params)
    end
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def set_observed_members_attributes
    params['user']['observed_members_attributes'] = ObservedMember.convert_params_to_attributes(current_user.id, JSON.parse(params[:observed_members_attributes]))
  end
end
