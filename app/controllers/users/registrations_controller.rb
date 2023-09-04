# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  def edit
    slack_client = Slack::Web::Client.new
    @channels_response = slack_client.conversations_list['channels']

    @channels_response.each do |channel_response|
      SlackChannel.find_or_create_by!(channel_id: channel_response['id']) do |channel|
        channel.name = channel_response['name']
      end
    end
    super
  end

  def update
    attrs = JSON.parse(params[:observed_members_attributes]).map do |channel_members_param|
      channel_members_param['members'].map do |channel_member|
        attr = { 'user_id' => current_user.id,
                 'channel_member_id' => channel_member['channel_member_id'] }
        attr['_destroy'] = true unless channel_member['observe']
        attr
      end
    end.flatten
    params['user']['observed_members_attributes'] = attrs

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
                                        { observed_members_attributes: %i[user_id channel_member_id] }
                                      ])
  end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
