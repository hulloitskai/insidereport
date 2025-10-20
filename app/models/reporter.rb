# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: reporters
#
#  id                    :uuid             not null, primary key
#  journalistic_approach :text             not null
#  name                  :string           not null
#  personality           :text             not null
#  role                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  project_id            :uuid             not null
#
# Indexes
#
#  index_reporters_on_project_id           (project_id)
#  index_reporters_on_role_and_project_id  (role,project_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Reporter < ApplicationRecord
  # == Associations
  belongs_to :project

  # == Validations
  validates :name, :role, :personality, :journalistic_approach, presence: true
end
