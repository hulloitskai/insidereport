# rubocop:disable Layout/LineLength
# typed: true
# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :uuid do |t|
      ## Database authenticatable
      t.string :email,              null: false
      t.string :encrypted_password, null: false

      ## Recoverable
      t.string :reset_password_token
      t.timestamptz :reset_password_sent_at

      ## Rememberable
      t.timestamptz :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0, null: false
      t.timestamptz :current_sign_in_at
      t.timestamptz :last_sign_in_at
      t.inet :current_sign_in_ip
      t.inet :last_sign_in_ip

      ## Confirmable
      t.string :confirmation_token
      t.timestamptz :confirmed_at
      t.timestamptz :confirmation_sent_at
      t.string :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.timestamptz :locked_at

      t.string :name, null: false

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
end
