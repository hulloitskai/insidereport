# typed: true
# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    # == Filters
    # before_action :store_redirect_location!, only: :new

    # == Actions
    # GET /login
    def new
      render(inertia: "LoginPage", props: { failed: flash.alert.present? })
    end

    # POST /login
    def create
      user = warden.authenticate!(auth_options)
      sign_in(resource_name, user)
      render(json: {
        user: UserSerializer.one(user),
      })
    end

    # DELETE /logout
    def destroy
      if Devise.sign_out_all_scopes
        sign_out
      else
        sign_out(resource_name)
      end
      render(json: {})
    end

    # private

    # # == Filter handlers
    # sig { void }
    # def store_redirect_location!
    #   if (url = params[:redirect_url].presence)
    #     raise "Redirect URL must be a string" unless url.is_a?(String)

    #     store_location_for(:user, url)
    #   end
    # end
  end
end
