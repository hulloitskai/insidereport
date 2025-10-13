# typed: true
# frozen_string_literal: true

class OrganizationsController < ApplicationController
  # == Filters
  before_action :authenticate_user!

  # == Actions
  # GET /organizations
  def index
    user = authenticate_user!
    organizations = user.owned_organizations.chronological
    render(json: {
      organizations: OrganizationSerializer.many(organizations),
    })
  end

  # GET /organizations/:id
  def show
    render(inertia: "OrganizationPage")
  end

  # GET /organizations/new
  def new
    render(inertia: "NewOrganizationPage")
  end

  # POST /organizations
  def create
    user = authenticate_user!
    organization_params = params.expect(organization: %i[
      name
      handle
      display_photo
    ])
    organization = user.owned_organizations.build(**organization_params)
    if organization.save
      render(json: {
        organization: OrganizationSerializer.one(organization),
      })
    else
      render(
        json: {
          errors: organization.form_errors,
        },
        status: :unprocessable_entity,
      )
    end
  end
end
