# typed: true
# frozen_string_literal: true

class OrganizationSerializer < ApplicationSerializer
  # == Attributes
  identifier
  attributes :name, :handle

  # == Associations
  has_one :display_photo, serializer: ImageSerializer
end
