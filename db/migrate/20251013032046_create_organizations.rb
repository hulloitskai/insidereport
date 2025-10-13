# typed: true
# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.string :handle, null: false, index: { unique: true }
      t.references :owner,
                   null: false,
                   foreign_key: { to_table: :users },
                   type: :uuid

      t.timestamps
    end
  end
end
