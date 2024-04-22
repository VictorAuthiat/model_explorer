# frozen_string_literal: true

Devise.setup do |config|
  require "devise/orm/active_record"

  config.mailer_sender = "disabled@example.com"
  config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.http_authenticatable = [:database]
  config.skip_session_storage = [:http_auth]
  config.stretches = 1
  config.send_email_changed_notification = false
  config.send_password_change_notification = false
  config.password_length = 0
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/
  config.sign_out_all_scopes = false
  config.sign_out_via = :delete
end
