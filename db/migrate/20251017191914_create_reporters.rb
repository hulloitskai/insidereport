# typed: true
# frozen_string_literal: true

class CreateReporters < ActiveRecord::Migration[8.0]
  def change
    create_table :reporters, id: :uuid do |t|
      t.belongs_to :project, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :role, null: false
      t.text :personality, null: false
      t.text :journalistic_approach, null: false
      t.index %i[role project_id], unique: true

      t.timestamps
    end
  end
end
