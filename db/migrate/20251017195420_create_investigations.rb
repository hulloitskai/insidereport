# typed: true
# frozen_string_literal: true

class CreateInvestigations < ActiveRecord::Migration[8.0]
  def change
    create_table :investigations, id: :uuid do |t|
      t.belongs_to :project, null: false, foreign_key: true, type: :uuid
      t.belongs_to :reporter, null: false, foreign_key: true, type: :uuid
      t.text :research_goal, null: false
      t.text :research_strategy, null: false
      t.text :research_findings, null: false
      t.tstzrange :period, null: false

      t.timestamps
    end
  end
end
