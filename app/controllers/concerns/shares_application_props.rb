# typed: true
# frozen_string_literal: true

module SharesApplicationProps
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  # == Annotations
  requires_ancestor { ApplicationController }

  included do
    T.bind(self, T.class_of(ApplicationController))

    inertia_share do
      {
        csrf: {
          param: request_forgery_protection_token,
          token: form_authenticity_token,
        },
        flash: flash.to_h,
      }
    end
  end
end
