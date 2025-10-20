# typed: true
# frozen_string_literal: true

require "readonly_sql_connection"
require "schema_dumper"

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: projects
#
#  id           :uuid             not null, primary key
#  database_url :string           not null
#  name         :string           not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :uuid             not null
#
# Indexes
#
#  index_projects_on_database_url  (database_url) UNIQUE
#  index_projects_on_owner_id      (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Project < ApplicationRecord
  # == Associations
  belongs_to :owner, class_name: "User", inverse_of: :owned_projects
  has_many :schema_snapshots, dependent: :destroy
  has_many :reporters, dependent: :destroy

  sig { returns(T.nilable(SchemaSnapshot)) }
  def current_schema_snapshot
    schema_snapshots.chronological.last
  end

  # == Normalizations
  normalizes :name, with: ->(name) { name.strip }

  # == Validations
  validates :name, presence: true
  validates :database_url, presence: true, uniqueness: true
  validate :validate_database_connection

  # == Callbacks
  after_create_commit :snapshot_schema_later

  # == Schema
  sig { returns(String) }
  def dump_schema
    dumper = SchemaDumper.new(database_url)
    dumper.dump
  end

  sig { params(force: T::Boolean).returns(SchemaSnapshot) }
  def snapshot_schema!(force: false)
    sql_schema = dump_schema
    if !force &&
        (current_schema = current_schema_snapshot) &&
        current_schema.sql_schema == sql_schema
      current_schema
    else
      processed_schema = SchemaSnapshot.process_schema(sql_schema, sql_conn:)
      schema_snapshots.create!(sql_schema:, processed_schema:)
    end
  end

  sig { void }
  def snapshot_schema_later
    SnapshotProjectSchemaJob.perform_later(self)
  end

  # == Reporters
  sig { params(force: T::Boolean).returns(T::Array[Reporter]) }
  def generate_reporters!(force: false)
    if !force && (reporters = reporters.to_a.presence)
      return reporters
    end

    company_analysis = current_schema_snapshot&.company_analysis or
      raise "Missing company analysis"

    response = OpenaiService.generate_response(
      prompt: {
        id: "pmpt_68f298c889e0819796a2a08c3d751ee10bc0ca3c851a79d9",
        variables: {
          company_analysis:,
        },
      },
    )
    output_text = OpenaiService.output_text!(response)
    result = JSON.parse(output_text)
    self.reporters = result.fetch("company_reporters").map do |attributes|
      Reporter.new(**attributes)
    end
  end

  # == Methods
  sig { returns(ReadonlySqlConnection) }
  def readonly_sql_connection
    ReadonlySqlConnection.new(database_url)
  end

  sig { void }
  def test_database_connection!
    readonly_sql_connection.test_connection!
  end

  sig { returns(String) }
  def sql_dialect
    uri = URI.parse(database_url)
    case uri.scheme
    when "postgres", "postgresql", "postgis"
      "PostgreSQL"
    when "mysql", "mysql2"
      "MySQL"
    when "sqlite3"
      "SQLite"
    else
      raise "Unsupported database scheme: #{uri.scheme}"
    end
  end

  sig { returns(ReadonlySqlConnection) }
  def sql_conn
    ReadonlySqlConnection.new(database_url)
  end

  sig { params(sql: String, safeguard_output: T::Boolean).returns(String) }
  def execute_sql(sql, safeguard_output: false)
    sql_conn.execute_sql(sql, safeguard_output:)
  end

  private

  # == Validators
  sig { void }
  def validate_database_connection
    if (url = database_url.presence)
      conn = ReadonlySqlConnection.new(url)
      begin
        conn.test_connection!
      rescue StandardError => error
        errors.add(
          :database_url,
          :invalid,
          message: "connection failed: #{error.message}",
        )
      end
    end
  end
end
