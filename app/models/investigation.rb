# typed: true
# frozen_string_literal: true

# rubocop:disable Layout/LineLength, Lint/RedundantCopDisableDirective
# == Schema Information
#
# Table name: investigations
#
#  id                :uuid             not null, primary key
#  period            :tstzrange        not null
#  research_findings :text             not null
#  research_goal     :text             not null
#  research_strategy :text             not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  project_id        :uuid             not null
#  reporter_id       :uuid             not null
#
# Indexes
#
#  index_investigations_on_project_id   (project_id)
#  index_investigations_on_reporter_id  (reporter_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id)
#  fk_rails_...  (reporter_id => reporters.id)
#
# rubocop:enable Layout/LineLength, Lint/RedundantCopDisableDirective
class Investigation < ApplicationRecord
  # == Associations
  belongs_to :project
  belongs_to :reporter

  # == Validations
  validates :period,
            :research_goal,
            :research_strategy,
            :research_findings,
            presence: true
end
