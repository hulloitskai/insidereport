# typed: true
# frozen_string_literal: true

module Users
  class DeviseMailer < Devise::Mailer
    extend T::Sig

    # == Emails
    sig do
      override
        .params(record: User, token: String, opts: T::Hash[Symbol, T.untyped])
        .returns(Mail::Message)
    end
    def confirmation_instructions(record, token, opts = {})
      devise_mail(record, :confirmation_instructions, opts.merge({
        inertia: "UserEmailVerificationEmail",
        props: {
          user: UserSerializer.one(record),
          "verificationUrl" => user_confirmation_url(confirmation_token: token),
        },
      }))
    end

    sig do
      override
        .params(record: User, token: String, opts: T::Hash[Symbol, T.untyped])
        .returns(Mail::Message)
    end
    def reset_password_instructions(record, token, opts = {})
      reset_url = edit_user_password_url(reset_password_token: token)
      devise_mail(record, :reset_password_instructions, opts.merge({
        inertia: "UserPasswordResetEmail",
        props: {
          user: UserSerializer.one(record),
          "resetUrl" => reset_url,
        },
      }))
    end

    sig do
      override
        .params(record: User, opts: T::Hash[Symbol, T.untyped])
        .returns(Mail::Message)
    end
    def email_changed(record, opts = {})
      devise_mail(record, :email_changed, opts.merge({
        inertia: "UserEmailChangedEmail",
        props: {
          user: UserSerializer.one(record),
        },
      }))
    end

    sig do
      override
        .params(record: User, opts: T::Hash[Symbol, T.untyped])
        .returns(Mail::Message)
    end
    def password_change(record, opts = {})
      devise_mail(record, :password_change, opts.merge({
        inertia: "UserPasswordChangedEmail",
        props: {
          user: UserSerializer.one(record),
        },
      }))
    end
  end
end
