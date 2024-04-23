require_relative "model_explorer/version"
require_relative "model_explorer/engine" if defined?(Rails)

module ModelExplorer
  autoload :Configuration, "model_explorer/configuration"
  autoload :Export, "model_explorer/export"
  autoload :Import, "model_explorer/import"

  class << self
    def configure
      yield configuration
    end

    def configuration
      @_configuration ||= Configuration.new
    end

    # Import a record and its associations from a JSON export
    # @param json_record [String] JSON record
    # @return [ActiveRecord::Base]
    def import(json_record)
      record_data = JSON.parse(json_record)

      Import.new(record_data).import
    end
  end
end
