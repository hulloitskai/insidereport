# typed: true
# frozen_string_literal: true

class RenameOrganizationsToProjects < ActiveRecord::Migration[8.0]
  def change
    rename_table :organizations, :projects
  end
end
