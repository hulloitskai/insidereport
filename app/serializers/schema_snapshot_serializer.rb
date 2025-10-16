# typed: true
# frozen_string_literal: true

class SchemaSnapshotSerializer < ApplicationSerializer
  # == Attributes
  identifier
  attributes :processed_schema, :company_analysis, :additional_notes
end
