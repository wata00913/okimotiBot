json.channel_members @channel_members_info do |member_info|
  json.account_id member_info['id']
  json.name member_info['real_name']
  json.image_url member_info['profile']['image_original']
end
