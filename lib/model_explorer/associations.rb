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

    def self.build_from_params(associations_params)
      associations = associations_params.dig("association_attributes", "associations") || {}

      associations.map do |_index, association_params|
        attributes = association_params["association_attributes"]

        {
          name: attributes["name"],
          scopes: attributes["scopes"],
          columns: attributes["columns"],
          associations: build_from_params(association_params)
        }
      end
    end
  end
end
