# typed: true
# frozen_string_literal: true

class ProjectsController < ApplicationController
  # == Filters
  before_action :authenticate_user!

  # == Actions
  # GET /projects
  def index
    user = authenticate_user!
    projects = user.owned_projects.chronological
    render(json: {
      projects: ProjectSerializer.many(projects),
    })
  end

  # GET /projects/:id
  def show
    project_id = params.fetch(:id)
    project = Project.find(project_id)
    render(
      inertia: "ProjectPage",
      props: {
        project: ProjectSerializer.one(project),
      },
    )
  end

  # GET /projects/new
  def new
    render(inertia: "NewProjectPage")
  end

  # POST /projects
  def create
    user = authenticate_user!
    project_params = params.expect(project: %i[
      name
      database_url
    ])
    project = user.owned_projects.build(**project_params)
    if project.save
      render(json: {
        project: ProjectSerializer.one(project),
      })
    else
      render(
        json: {
          errors: project.form_errors,
        },
        status: :unprocessable_entity,
      )
    end
  end
end
