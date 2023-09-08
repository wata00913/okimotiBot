json.channels SlackChannel.all do |slack_channel|
  json.channel_id slack_channel.channel_id
  json.name slack_channel.name
end

json.updated_at l(@updated_at, format: :long)
