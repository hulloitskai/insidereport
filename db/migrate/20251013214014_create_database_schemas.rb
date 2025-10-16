# typed: true
# frozen_string_literal: true

class CreateDatabaseSchemas < ActiveRecord::Migration[8.0]
  def change
    create_table :database_schemas, id: :uuid do |t|
      t.belongs_to :project, null: false, foreign_key: true, type: :uuid
      t.text :sql_dump, null: false
      t.text :processed_schema, null: false
      t.text :additional_notes

      t.timestamps
    end
  end
end
