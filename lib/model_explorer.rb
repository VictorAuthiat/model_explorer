require_relative "model_explorer/engine" if defined?(Rails)
require "active_support/core_ext/module/attribute_accessors"

require_relative "model_explorer/version"
require_relative "model_explorer/associations"

module ModelExplorer
  autoload :Export, "model_explorer/export"
  autoload :Import, "model_explorer/import"
  autoload :Scopes, "model_explorer/scopes"

  # Custom proc to verify access to the form
  # @param controller [ActionController::Base]
  mattr_accessor :verify_access_proc, default: ->(_controller) { true }

  # Attributes to filter out from the search results
  # Attributes will be replaced with "---FILTERED---"
  # @param filter_attributes_regexp [Regexp]
  mattr_accessor :filter_attributes_regexp, default: /password|secret|token/i

  # Enable basic authentication
  mattr_accessor :basic_auth_enabled, default: false
  mattr_accessor :basic_auth_username, default: "admin"
  mattr_accessor :basic_auth_password, default: "password"

  def self.configure
    yield(self)
  end

  # Import a record and its associations from a JSON export
  # @param json_record [String] JSON record
  # @return [ActiveRecord::Base]
  def self.import(json_record)
    record_data = JSON.parse(json_record)

    Import.new(record_data).import
  end
end
