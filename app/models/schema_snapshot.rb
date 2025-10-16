# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: schema_snapshots
#
#  id               :uuid             not null, primary key
#  additional_notes :text
#  company_analysis :text
#  processed_schema :jsonb            not null
#  sql_schema       :text             not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  project_id       :uuid             not null
#
# Indexes
#
#  index_schema_snapshots_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class SchemaSnapshot < ApplicationRecord
  # == Associations
  belongs_to :project

  sig { returns(Project) }
  def project!
    project or raise ActiveRecord::RecordNotFound, "Missing associated project"
  end

  # == Normalizations
  normalizes :additional_notes, with: ->(value) { value.strip.presence }

  # == Validations
  validates :sql_schema, :processed_schema, presence: true

  # == Callbacks
  after_create_commit :analyze_company_later

  # == Company analysis
  sig { returns(TrueClass) }
  def analyze_company!
    company_analysis = generate_company_analysis
    update!(company_analysis:)
  end

  sig { void }
  def analyze_company_later
    AnalyzeSchemaSnapshotCompanyJob.perform_later(self)
  end

  # == Methods
  sig { params(table_name: String).returns(T::Hash[String, T.untyped]) }
  def table_schema(table_name)
    processed_schema.fetch("tables").find do |table|
      table.fetch("name") == table_name
    end
  end

  # == Helpers
  sig { params(sql_schema: String).returns(T::Hash[String, T.untyped]) }
  def self.process_schema(sql_schema)
    response = OpenaiService.generate_response(
      prompt: {
        id: "pmpt_68ed772586c081979e135f328fb3ba1b0134039ddf26db29",
        variables: {
          sql_schema:,
        },
      },
    )
    output_text = OpenaiService.output_text(response) or raise "No output"
    tag_logger("process_schema") do
      logger.debug("OpenAI response: #{output_text.inspect}")
    end
    JSON.parse(output_text)
  end

  private

  # == Helpers
  sig { returns(String) }
  def generate_company_analysis
    project = project!

    # Initial request
    prompt = {
      id: "pmpt_68eeba25f4a081958b0782afd91919ae0c6bb2c047ce2e0d",
      variables: {
        sql_dialect: project.sql_dialect,
        schema: processed_schema.to_s,
      },
    }
    response = OpenaiService.generate_response(prompt:)

    # Keep handling tool calls until we get a text response
    loop do
      text_response = T.let(nil, T.nilable(String))
      sql_outputs = T.let(
        [],
        T::Array[OpenAI::Responses::ResponseInputItem::FunctionCallOutput],
      )

      response.output.each do |item|
        if item.is_a?(OpenAI::Responses::ResponseOutputMessage)
          text_response = item.content.filter_map do |content|
            if content.is_a?(OpenAI::Responses::ResponseOutputText)
              content.text
            end
          end.join(" ")
        elsif item.is_a?(OpenAI::Responses::ResponseFunctionToolCall)
          parsed_arguments = JSON.parse(item.arguments)
          query = parsed_arguments.fetch("query")
          output = project.execute_sql(query, safeguard_output: true)
          sql_outputs <<
            OpenAI::Responses::ResponseInputItem::FunctionCallOutput.new(
              call_id: item.call_id,
              output:,
            )
        end
      end

      if sql_outputs.empty?
        if text_response.present?
          break text_response
        else
          raise "No text response and no tool call outputs to respond with"
        end
      else
        response = OpenaiService.generate_response(
          prompt:,
          previous_response_id: response.id,
          input: sql_outputs,
        )
      end
    end
  end
end
