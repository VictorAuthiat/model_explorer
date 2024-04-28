# frozen_string_literal: true

module ModelExplorer
  class Engine < ::Rails::Engine
    isolate_namespace ModelExplorer

    config.generators do |generators|
      generators.test_framework :rspec
      generators.assets false
      generators.helper false
    end

    initializer "model_explorer.assets.precompile" do |app|
      app.config.assets.precompile += [
        "model_explorer/application.css",
        "model_explorer/application.js"
      ]
    end

    initializer :i18n_load_path do |app|
      ActiveSupport.on_load(:i18n) do
        engine_i18n_load_path = Dir[Engine.root.join("config/locales/**/model_explorer/**/*.yml").to_s]
        app.config.i18n.load_path = engine_i18n_load_path.concat(app.config.i18n.load_path)
      end
    end

    initializer :scopes do |_app|
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.include ModelExplorer::Scopes
      end
    end

    initializer :eager_load_models do
      Rails.application.config.to_prepare do
        Rails.autoloaders.main.eager_load_dir(Rails.root.join("app/models"))
      end
    end
  end
end
