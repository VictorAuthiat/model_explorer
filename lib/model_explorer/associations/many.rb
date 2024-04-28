module ModelExplorer
  module Associations
    class Many < Base
      def export
        {
          name: name,
          type: macro,
          scopes: scopes,
          count: relation.count,
          records: export_records
        }
      end

      def relation
        ensure_valid_scopes!

        scopes.inject(default_relation) do |relation, scope|
          relation.public_send(scope)
        end
      end

      private

      def scopes
        association[:scopes] || []
      end

      def ensure_valid_scopes!
        model_explorer_scopes = klass.model_explorer_scopes.map(&:to_s)

        scopes.each do |scope|
          next if model_explorer_scopes.include?(scope)

          raise ArgumentError, "Unknown scope #{scope} for #{klass.name}"
        end
      end
    end
  end
end
