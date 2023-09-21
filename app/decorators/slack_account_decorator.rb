# frozen_string_literal: true

module SlackAccountDecorator
  def default_or_image_url
    image_url || 'user_icon.png'
  end
end
