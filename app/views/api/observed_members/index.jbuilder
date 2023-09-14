json.observed_members @observed_members.each do |channel, observed_members|
  json.channel do
    json.id channel.channel_id
    json.name channel.name
  end

  json.members observed_members.each do |observed_member|
    json.id observed_member.id
    json.channel_member_id observed_member.channel_member_id
    json.name observed_member.slack_account.name
    json.image_url observed_member.slack_account.image_url
  end
end
