# typed: true
# frozen_string_literal: true

class RenameDatabaseSchemasToSchemaSnapshots < ActiveRecord::Migration[8.0]
  def change
    rename_table :database_schemas, :schema_snapshots
  end
end
