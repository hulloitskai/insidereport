# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: users
#
#  id                     :uuid             not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :inet
#  email                  :string           not null
#  encrypted_password     :string           not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :inet
#  name                   :string           not null
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  sign_in_count          :integer          default(0), not null
#  unconfirmed_email      :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class User < ApplicationRecord
  # == Constants
  MIN_PASSWORD_ENTROPY = 14

  # == Devise
  # Others available are:
  # :lockable, :timeoutable, and :omniauthable
  devise :database_authenticatable,
         :argon2,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :trackable,
         allow_unconfirmed_access_for: nil

  self.filter_attributes += %i[
    encrypted_password
    reset_password_token
    confirmation_token
  ]

  # == Attributes
  sig { returns(String) }
  def email_domain
    parts = T.cast(email.split("@"), [String, String])
    parts.last
  end

  sig { returns(String) }
  def email_with_name
    ActionMailer::Base.email_address_with_name(email, name)
  end

  # == Associations
  has_many :owned_projects,
           class_name: "Project",
           foreign_key: :owner_id,
           inverse_of: :owner,
           dependent: :restrict_with_error

  sig { returns(T.nilable(Project)) }
  def primary_project
    owned_projects.chronological.first
  end

  # == Normalizations
  normalizes :name, with: ->(value) { value.strip }
  normalizes :email, with: ->(value) { value.strip.downcase }

  # == Validations
  validates :name, presence: true
  validates :email,
            presence: true,
            uniqueness: true,
            email: true
  validates :password,
            password_strength: {
              min_entropy: MIN_PASSWORD_ENTROPY,
              use_dictionary: true,
            },
            allow_nil: true

  # == Callbacks
  before_validation :remove_unconfirmed_email_if_matches_email,
                    if: %i[unconfirmed_email? email_changed?]

  protected

  # == Callback handlers
  sig { override.void }
  def after_confirmation
    super
    # send_welcome_email if confirmed_at_previously_was.nil?
  end

  private

  # == Callback handlers
  sig { void }
  def remove_unconfirmed_email_if_matches_email
    self.unconfirmed_email = nil if email == unconfirmed_email
  end
end
