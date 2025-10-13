# typed: strict
# frozen_string_literal: true

module ApplicationCable
  class Connection < ActionCable::Connection::Base
    extend T::Sig
    extend T::Helpers

    # == Configuration
    identified_by :current_user, :current_friend

    # == Connection
    sig { void }
    def connect
      reject_unauthorized_connection
    end
  end
end
