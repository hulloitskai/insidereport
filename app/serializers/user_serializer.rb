# typed: true
# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  # == Attributes
  identifier
  attributes :email,
             :name,
             unconfirmed_email: {
               type: :string,
               nullable: true,
             }
end
