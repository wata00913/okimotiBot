# frozen_string_literal: true

class Api::ObservedMembersController < ActionController::API
  def index
    @observed_members = current_user.observed_members
      .to_ary.group_by { |m| m.channel_member.slack_channel }
      .map do |channel, observed_members|
        data = {}
        data['channel'] = { 'id' => channel.channel_id, 'name' => channel.name }
        data['members'] = observed_members.map do |observed_member|
          account = observed_member.channel_member.slack_account
          { 'channel_member_id' => observed_member.channel_member_id,
            'name' => account.name,
            'image_url' => account.image_url }
        end
        data
      end
  end
end
