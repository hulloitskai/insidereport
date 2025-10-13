# typed: true
# frozen_string_literal: true

class HomeController < ApplicationController
  # == Actions
  # GET /home
  def redirect
    redirect_to(redirect_path)
  end

  private

  # == Helpers
  sig { returns(String) }
  def redirect_path
    if (user = current_user)
      if (organization = user.primary_organization)
        organization_path(organization)
      else
        new_organization_path
      end
    else
      root_path
    end
  end
end
