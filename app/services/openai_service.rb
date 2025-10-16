# typed: true
# frozen_string_literal: true

class OpenaiService < ApplicationService
  sig { void }
  def initialize
    super
    @client = OpenAI::Client.new(api_key: self.class.credentials!.api_key!)
  end

  sig { returns(OpenAI::Client) }
  attr_reader :client

  # == Methods
  sig do
    params(
      prompt: T.nilable(OpenAI::Responses::ResponsePrompt::OrHash),
      previous_response_id: T.nilable(String),
      input: OpenAI::Responses::ResponseCreateParams::Input::Variants,
    ).returns(OpenAI::Responses::Response)
  end
  def self.generate_response(prompt: nil, previous_response_id: nil, input: [])
    arguments = { prompt:, previous_response_id:, input: }.compact
    tag_logger do
      logger.debug("Generating response for:")
      logger.debug(arguments.pretty_inspect)
    end
    response = instance.client.responses.create(**arguments)
    tag_logger do
      logger.debug("Generated response:")
      logger.debug(response.output.pretty_inspect)
    end
    response
  end

  # == Helpers
  sig { returns(T.untyped) }
  def self.credentials!
    Rails.application.credentials.openai!
  end

  sig do
    params(response: OpenAI::Responses::Response).returns(T.nilable(String))
  end
  def self.output_text(response)
    response.output.each do |output|
      next unless output.is_a?(OpenAI::Models::Responses::ResponseOutputMessage)

      return output.content.filter_map do |content|
        next unless content.is_a?(OpenAI::Models::Responses::ResponseOutputText)

        content.text
      end.join(" ")
    end
    nil
  end

  sig { params(response: OpenAI::Responses::Response).returns(T.anything) }
  def self.parsed_output(response)
    response.output.each do |output|
      next unless output.is_a?(OpenAI::Models::Responses::ResponseOutputMessage)

      output.content.each do |content|
        next unless content.is_a?(OpenAI::Models::Responses::ResponseOutputText)

        return content.parsed
      end
    end
    nil
  end
end
