# typed: true
# frozen_string_literal: true

class ProjectSerializer < ApplicationSerializer
  # == Attributes
  identifier
  attributes :name

  # == Associations
  has_one :current_schema_snapshot, serializer: SchemaSnapshotSerializer
  has_many :reporters, serializer: ReporterSerializer
end
