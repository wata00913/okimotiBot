# frozen_string_literal: true

class AwsComprehendClient
  LANGUAGE_CODE = 'ja'
  BATCH_SIZE = 25

  def initialize
    @client = Aws::Comprehend::Client.new
  end

  def analyze_sentiment(request)
    batch_request = request.each_slice(BATCH_SIZE)

    response = { 'success' => [], 'failure' => [] }
    batch_request.each do |subset|
      result = @client.batch_detect_sentiment(build_batch_params(subset))

      ids = subset.map { |s| s[:id] }
      success, failure = build_response(result, ids)

      response['success'].concat(success)
      response['failure'].concat(failure)
    end
    response
  end

  private

  def build_batch_params(request)
    {
      text_list: request.map { |r| r[:original_message] },
      language_code: LANGUAGE_CODE
    }
  end

  def build_response(result, ids)
    success = result.result_list.map do |r|
      {
        'id' => ids[r.index],
        'positive' => r.sentiment_score.positive,
        'negative' => r.sentiment_score.negative,
        'neutral' => r.sentiment_score.neutral,
        'mixed' => r.sentiment_score.mixed,
        'sentiment' => r.sentiment.downcase
      }
    end

    failure = result.error_list.map do |e|
      {
        'id' => ids[e.index],
        'error_code' => e.error_code,
        'error_message' => e.error_message
      }
    end
    [success, failure]
  end
end
