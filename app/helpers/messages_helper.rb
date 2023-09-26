# frozen_string_literal: true

module MessagesHelper
  def unanalyzed_messages_num
    Message.unanalyzed.size
  end
end
