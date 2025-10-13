# typed: true
# frozen_string_literal: true

# Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  # == Redirects
  constraints SubdomainConstraint do
    get "(*any)" => redirect(subdomain: "", status: 302)
  end

  # == Errors
  scope controller: :errors, constraints: { format: %w[html json] } do
    get "/401", action: :unauthorized
    get "/404", action: :not_found
    get "/422", action: :unprocessable_entity
    get "/500", action: :internal_server_error
  end

  # == Healthcheck
  defaults constraints: { format: "json" }, export: true do
    Healthcheck.routes(self)
  end

  # == Good Job
  mount GoodJob::Engine => "/good_job"

  # == Attachments
  resources :files,
            only: :show,
            param: :signed_id,
            constraints: { format: "json" },
            export: true
  resources(
    :images,
    only: :show,
    param: :signed_id,
    constraints: { format: "json" },
    export: true,
  ) do
    member do
      get :download
    end
  end

  # == Contact
  resource :contact_url,
           only: :show,
           constraints: { format: "json" },
           export: { namespace: "contact_url" }

  # == Devise
  devise_for :users,
             skip: %i[registration confirmation password],
             controllers: { sessions: "users/sessions" },
             path: "/",
             path_names: { sign_in: "login", sign_out: "logout" }

  devise_scope :user do
    scope module: :users, as: :user, export: true do
      resource :registration,
               path: "/signup",
               only: :new,
               path_names: { new: "" },
               constraints: { format: "html" }
      resource :registration,
               path: "/signup",
               only: %i[create],
               constraints: { format: "json" }
      resource :registration,
               path: "/settings",
               only: :edit,
               path_names: { edit: "" },
               constraints: { format: "html" }
      resource :registration,
               path: "/settings",
               only: :update,
               constraints: { format: "json" }
      resource :confirmation,
               path: "/email_verification",
               only: %i[new show],
               path_names: { new: "resend" },
               constraints: { format: "html" }
      resource :confirmation,
               path: "/email_verification",
               only: :create,
               constraints: { format: "json" }
      resource :password,
               only: %i[new edit],
               path_names: { new: "reset", edit: "change" },
               constraints: { format: "html" }
      resource :password,
               only: %i[create update],
               constraints: { format: "json" }
    end
  end

  # == Organizations
  resources :organizations,
            only: %i[index create],
            constraints: { format: "json" },
            export: true
  resources :organizations,
            only: %i[show new],
            constraints: { format: "json" },
            export: true

  # == Home
  get "/home" => "home#redirect", export: true

  # == Pages
  root "landing#show", export: true

  # == Devtools
  if Rails.env.development?
    scope export: { namespace: "test" } do
      get "/test" => "test#show", constraints: { format: "html" }
      post "/test/submit" => "test#submit", constraints: { format: "json" }
    end
    get "/mailcatcher" => redirect("//localhost:1080", status: 302),
        constraints: { format: "html" }
  end
end
