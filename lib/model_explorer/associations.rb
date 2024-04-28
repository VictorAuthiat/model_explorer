module ModelExplorer
  module Associations
    autoload :Base, "model_explorer/associations/base"
    autoload :Many, "model_explorer/associations/many"
    autoload :Singular, "model_explorer/associations/singular"

    def self.build(record, reflection, association)
      case reflection&.macro
      when :has_many
        ModelExplorer::Associations::Many.new(record, reflection, association)
      when :has_one, :belongs_to
        ModelExplorer::Associations::Singular.new(record, reflection, association)
      else
        raise "Unknown association #{association[:name]}"
      end
    end
  end
end
