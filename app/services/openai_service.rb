# typed: true
# frozen_string_literal: true

require "readonly_sql_connection"

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

  sig do
    params(
      prompt: OpenAI::Responses::ResponsePrompt::OrHash,
      sql_conn: ReadonlySqlConnection,
    ).returns(OpenAI::Responses::Response)
  end
  def self.generate_response_with_database_tools(prompt:, sql_conn:)
    response = generate_response(prompt:)
    loop do
      tool_calls = output_tool_calls(response)

      # If no tool calls, return the text response
      if tool_calls.empty?
        break response
      end

      # Execute SQL queries and collect the outputs
      sql_outputs = tool_calls.map do |tool_call|
        if tool_call.name != "execute_sql"
          raise "Unsupported tool call: #{tool_call.name}"
        end

        parsed_arguments = JSON.parse(tool_call.arguments)
        query = parsed_arguments.fetch("query")
        output = begin
          sql_conn.execute_sql(query, safeguard_output: true)
        rescue ActiveRecord::StatementInvalid => error
          "Invalid statement: #{error.message}"
        end
        OpenAI::Responses::ResponseInputItem::FunctionCallOutput.new(
          call_id: tool_call.call_id,
          output:,
        )
      end

      # Generate next response with the SQL outputs
      previous_response_id = response.id
      response = OpenaiService.generate_response(
        prompt:,
        previous_response_id:,
        input: sql_outputs,
      )
    end
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

  sig { params(response: OpenAI::Responses::Response).returns(String) }
  def self.output_text!(response)
    output_text(response) or raise "Missing output"
  end

  sig do
    params(response: OpenAI::Responses::Response)
      .returns(T::Array[OpenAI::Responses::ResponseFunctionToolCall])
  end
  def self.output_tool_calls(response)
    response.output.grep(OpenAI::Responses::ResponseFunctionToolCall)
  end

  # rubocop:disable Layout/LineLength
  # sig { params(response: OpenAI::Responses::Response).returns(T.anything) }
  # def self.parsed_output(response)
  #   response.output.each do |output|
  #     next unless output.is_a?(OpenAI::Models::Responses::ResponseOutputMessage)

  #     output.content.each do |content|
  #       next unless content.is_a?(OpenAI::Models::Responses::ResponseOutputText)

  #       return content.parsed
  #     end
  #   end
  #   nil
  # end
  # rubocop:enable Layout/LineLength
end
