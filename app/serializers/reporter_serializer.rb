# typed: true
# frozen_string_literal: true

class ReporterSerializer < ApplicationSerializer
  identifier
  attributes :name, :role, :personality, :journalistic_approach
end
