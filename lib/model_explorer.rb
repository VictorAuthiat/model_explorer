require_relative "model_explorer/version"
require_relative "model_explorer/engine" if defined?(Rails)

module ModelExplorer
  autoload :Export, "model_explorer/export"
end
