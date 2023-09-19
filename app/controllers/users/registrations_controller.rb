# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [:update]
  before_action :set_observed_members_attributes, only: [:update]

  def edit
    begin
      channels_response = slack_client.fetch_channels

      channel_ids = channels_response.map(&:id)
      SlackChannel.will_deleted(channel_ids).discard_all

      SlackChannel.create_channels(channels_response)
    rescue Slack::Web::Api::Errors::NotAuthed, Slack::Web::Api::Errors::InvalidAuth
      flash[:alert] = 'SlackAPIの認証に失敗しました。'
    rescue Slack::Web::Api::Errors::TimeoutError
      flash[:alert] = 'Slackチャンネルの取得に失敗しました。'
    end
    super
  end

  protected

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

  private

  def set_observed_members_attributes
    params['user']['observed_members_attributes'] = ObservedMember.convert_params_to_attributes(current_user.id, JSON.parse(params[:observed_members_attributes]))
  end
end
