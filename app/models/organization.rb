# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: organizations
#
#  id         :uuid             not null, primary key
#  handle     :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  owner_id   :uuid             not null
#
# Indexes
#
#  index_organizations_on_handle    (handle) UNIQUE
#  index_organizations_on_owner_id  (owner_id)
#
# Foreign Keys
#
#  fk_rails_...  (owner_id => users.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Organization < ApplicationRecord
  extend FriendlyId

  # == FriendlyId
  friendly_id :handle, slug_column: :handle

  # == Associations
  belongs_to :owner, class_name: "User", inverse_of: :owned_organizations
  has_one_attached :display_photo

  # == Normalizations
  normalizes :name, with: ->(name) { name.strip }

  # == Validations
  validates :name, :handle, presence: true
end
