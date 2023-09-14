# frozen_string_literal: true

class Api::SlackChannels::MembersController < Api::ApplicationController
  include SlackApiErrorHandler

  def index
    channel_id = params[:slack_channel_id]

    member_ids_response = slack_client.fetch_member_ids(channel_id)

    members_response = member_ids_response.map { |id| slack_client.fetch_account(id) }
    @channel = SlackChannel.find_by(channel_id:)
    @channel.find_or_create_members_by_attrs!(members_response, account_id_key: :id, name_key: :real_name, image_url_key: %i[profile image_original])
  end
end
