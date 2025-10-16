# typed: strict
# frozen_string_literal: true

class SnapshotProjectSchemaJob < ApplicationJob
  # == Configuration
  good_job_control_concurrency_with(
    key: -> {
      T.bind(self, SnapshotProjectSchemaJob)
      project, = arguments
      "#{self.class.name}(#{project.to_gid})"
    },
    total_limit: 1,
  )

  # == Job
  sig { params(project: Project).void }
  def perform(project)
    project.snapshot_schema!
  end
end
