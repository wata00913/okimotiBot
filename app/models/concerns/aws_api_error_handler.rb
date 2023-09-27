# frozen_string_literal: true

require 'active_support/concern'

module AwsApiErrorHandler
  extend ActiveSupport::Concern

  included do
    rescue_from Aws::Errors::MissingRegionError, with: :missing_resion
    rescue_from Aws::Comprehend::Errors::CredentialsError, with: :credentials
    rescue_from Aws::Comprehend::Errors::InvalidSignatureException, with: :invalid_signature
    rescue_from Aws::Comprehend::Errors::UnrecognizedClientException, with: :unrecognized
  end

  def missing_resion(e)
    write_log(e)
    render_flash('感情解析に失敗しました。')
  end

  def credentials(e)
    write_log(e)
    render_flash('感情解析に失敗しました。')
  end

  def invalid_signature(e)
    write_log(e)
    render_flash('感情解析に失敗しました。')
  end

  def unrecognized(e)
    write_log(e)
    render_flash('感情解析に失敗しました。')
  end

  def render_flash(alert_msg)
    flash['alert'] = alert_msg
    render turbo_stream: [
      turbo_stream.update('notice-or-alert-message', partial: 'layouts/flash')
    ]
  end
end
