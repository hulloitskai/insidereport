# typed: true
# frozen_string_literal: true

class AddDatabaseUrlToProjects < ActiveRecord::Migration[8.0]
  def change
    remove_column :projects, :handle
    add_column :projects, :database_url, :string, null: false
    add_index :projects, :database_url, unique: true
  end
end
