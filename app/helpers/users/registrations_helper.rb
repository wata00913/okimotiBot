# frozen_string_literal: true

module Users::RegistrationsHelper
  def checked?(observed_channel_ids, channel_id)
    observed_channel_ids.include?(channel_id)
  end
end
