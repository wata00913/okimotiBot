# frozen_string_literal: true

alice = User.create(
  name: 'alice',
  email: 'test@example.com',
  password: 'testtest'
)

User.create(
  name: 'bob',
  email: 'test1@example.com',
  password: 'testtest'
)

wata_minute_report_channel = SlackChannel.create(
  channel_id: '1',
  name: 'wataの分報'
)

tanaka_minute_report_channel = SlackChannel.create(
  channel_id: '2',
  name: 'tanakaの分報'
)

wata = SlackAccount.create(
  account_id: '1',
  name: 'wata00913'
)

tanaka = SlackAccount.create(
  account_id: '2',
  name: 'tanaka'
)

wata_minute_report_channel.accounts << [wata, tanaka]
tanaka_minute_report_channel.accounts << tanaka

alice.channel_members << wata_minute_report_channel.channel_members

attrs = [*(1..50)].map do |i|
  { slack_timestamp: (Date.yesterday.midnight - i.hour).to_f, original_message: "#{50 - i}番目のメッセージです。" }
end
alice.channel_members.first.messages.create(
  [
    { slack_timestamp: Time.zone.now.to_f, original_message: 'タスクに着手します。' },
    { slack_timestamp: Date.yesterday.midnight.to_f, original_message: 'タスクが終わりませんでした。' }
  ].concat(attrs)
)
alice.channel_members.second.messages.create(
  [
    { slack_timestamp: (Time.zone.now - 1.hour).to_f, original_message: 'モデルの実装を行います' },
    { slack_timestamp: Date.yesterday.midnight.to_f, original_message: 'タスクが終わりました。' }
  ]
)

Message.limit(Message.all.size / 2).each do |message|
  message.create_sentiment_score(
    positive: rand,
    negative: rand,
    neutral: rand,
    mixed: rand
  )
end
