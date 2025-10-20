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
  sig do
    params(
      sql_schema: String,
      sql_conn: ReadonlySqlConnection,
    ).returns(T::Hash[String, T.untyped])
  end
  def self.process_schema(sql_schema, sql_conn:)
    response = OpenaiService.generate_response_with_database_tools(
      prompt: {
        id: "pmpt_68f28a5c49b881909fb4756c9b759e030e49e84b8701ac7c",
        variables: {
          sql_schema:,
        },
      },
      sql_conn:,
    )
    output_text = OpenaiService.output_text!(response)
    JSON.parse(output_text)
  end

  private

  # == Helpers
  sig { returns(String) }
  def generate_company_analysis
    project = project!
    response = OpenaiService.generate_response_with_database_tools(
      prompt: {
        id: "pmpt_68f28d3c8d988196a72877330f2b5ef70e0692431e203b7a",
        variables: {
          sql_dialect: project.sql_dialect,
          schema: processed_schema.to_s,
        },
      },
      sql_conn: project.sql_conn,
    )
    OpenaiService.output_text!(response)
  end
end
