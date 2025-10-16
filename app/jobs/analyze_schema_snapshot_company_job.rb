# typed: strict
# frozen_string_literal: true

class AnalyzeSchemaSnapshotCompanyJob < ApplicationJob
  # == Configuration
  good_job_control_concurrency_with(
    key: -> {
      T.bind(self, AnalyzeSchemaSnapshotCompanyJob)
      schema_snapshot, = arguments
      "#{self.class.name}(#{schema_snapshot.to_gid})"
    },
    total_limit: 1,
  )

  # == Job
  sig { params(schema_snapshot: SchemaSnapshot).void }
  def perform(schema_snapshot)
    schema_snapshot.analyze_company!
  end
end
