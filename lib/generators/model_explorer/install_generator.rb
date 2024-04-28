# frozen_string_literal: true

require "rails/generators/active_record"

module ModelExplorer
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    class_option :routes, desc: "Generate routes", type: :boolean, default: false

    def copy_initializer
      template "model_explorer.rb", "config/initializers/model_explorer.rb"
    end

    def add_model_explorer_routes
      return unless options.routes?

      route <<~ROUTE
        mount ModelExplorer::Engine, at: "/model_explorer"

      ROUTE
    end
  end
end
