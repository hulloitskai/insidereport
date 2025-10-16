# typed: true
# frozen_string_literal: true

class StoreProcessedSchemaAsJson < ActiveRecord::Migration[8.0]
  def change
    up_only do
      execute "DELETE FROM schema_snapshots"
    end
    remove_column :schema_snapshots, :processed_schema, :text, null: false
    add_column :schema_snapshots, :processed_schema, :jsonb, null: false
  end
end
