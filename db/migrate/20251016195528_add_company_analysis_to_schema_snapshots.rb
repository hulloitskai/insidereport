# typed: true
# frozen_string_literal: true

class AddCompanyAnalysisToSchemaSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_column :schema_snapshots, :company_analysis, :text
  end
end
