require_relative "model_explorer/version"
require_relative "model_explorer/engine" if defined?(Rails)

module ModelExplorer
  autoload :Export, "model_explorer/export"
  autoload :Import, "model_explorer/import"

  # Import a record and its associations from a JSON export
  # @param json_record [String] JSON record
  # @return [ActiveRecord::Base]
  def self.import(json_record)
    Import.new(json_record).import
  end
end
