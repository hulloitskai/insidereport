# typed: true
# frozen_string_literal: true

class SchemaSnapshotSerializer < ApplicationSerializer
  # == Attributes
  identifier
  attributes :company_analysis,
             :additional_notes,
             processed_schema: { type: "Record<string, any>" }
end
