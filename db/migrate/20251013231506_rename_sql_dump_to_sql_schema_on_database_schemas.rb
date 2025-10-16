# typed: true
# frozen_string_literal: true

class RenameSqlDumpToSqlSchemaOnDatabaseSchemas < ActiveRecord::Migration[8.0]
  def change
    rename_column :database_schemas, :sql_dump, :sql_schema
  end
end
