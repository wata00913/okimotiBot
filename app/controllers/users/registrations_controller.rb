# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_account_update_params, only: [:update]
  before_action :set_observed_members_attributes, only: [:update]

  def edit
    begin
      channels_response = slack_client.fetch_channels
      SlackChannel.update_channels(channels_response)
    rescue Slack::Web::Api::Errors::NotAuthed, Slack::Web::Api::Errors::InvalidAuth
      flash[:alert] = 'SlackAPIの認証に失敗しました。'
    rescue Slack::Web::Api::Errors::TimeoutError
      flash[:alert] = 'Slackチャンネルの取得に失敗しました。'
    end

    @observed_channel_ids = current_user.observed_channels.pluck(:channel_id)
    @slack_channels = SlackChannel.all

    super
  end

  def update
    super do |user|
      next if user.errors.empty?

      flash['errors'] = user.errors.full_messages

      # 更新失敗のケースでrenderを使い設定画面を再反映する場合、
      # 前回ユーザーが入力した監視対象ユーザーのON/OFFスイッチの状態を引き継ぐことが困難。
      # そのためリダイレクトで対応する。
      # JSで実装した「監視対象ユーザーの表示処理」をTurboで置き換えた場合、このアクションの上書きは不要になる
      redirect_to edit_user_registration_path

      return
    end
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
