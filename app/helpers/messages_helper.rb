# frozen_string_literal: true

module MessagesHelper
  def unanalyzed_messages_num
    Message.unanalyzed.size
  end

  def latest_message_time(messages)
    timestamp = Message.latest_slack_timestamp(messages)
    timestamp.nil? ? '' : l(Time.zone.at(timestamp), format: :long)
  end
end
