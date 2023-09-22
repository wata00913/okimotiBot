json.channel_members @channel.channel_members.includes(:slack_channel, :slack_account) do |channel_member|
  json.channel_member_id channel_member.id
  json.name channel_member.slack_account.name
  json.image_url channel_member.slack_account.image_url
end
