# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Actions
  # GET /home
  def redirect
    redirect_to(redirect_path, status: :found)
  end

  private

  # == Helpers
  sig { returns(String) }
  def redirect_path
    if (user = current_user)
      if (project = user.primary_project)
        project_path(project)
      else
        new_project_path
      end
    else
      root_path
    end
  end
end
