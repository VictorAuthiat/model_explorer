# frozen_string_literal: true

module ModelExplorer
  class Configuration
    DEFAULT_BASIC_AUTH_USERNAME = "admin"
    DEFAULT_BASIC_AUTH_PASSWORD = "password"

    attr_accessor :basic_auth_enabled
    attr_accessor :basic_auth_username
    attr_accessor :basic_auth_password
    attr_accessor :verify_access_proc
    attr_accessor :filter_attributes_regexp

    def initialize
      @basic_auth_enabled = false
      @basic_auth_username = DEFAULT_BASIC_AUTH_USERNAME
      @basic_auth_password = DEFAULT_BASIC_AUTH_PASSWORD
      @verify_access_proc = ->(_controller) { true }
      @filter_attributes_regexp = /password|secret|token/i
    end

    def basic_auth_enabled?
      return false unless basic_auth_enabled

      basic_auth_username.present? && basic_auth_password.present?
    end
  end
end
