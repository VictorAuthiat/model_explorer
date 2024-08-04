module ModelExplorer
  module Associations
    class Many < Base
      def export
        {
          name: name,
          type: macro,
          scopes: scopes,
          count: records.count,
          records: export_records
        }
      end

      def records
        ensure_valid_scopes!

        super
      end

      private

      def query
        scopes.inject(default_query) do |relation, scope|
          relation.public_send(scope)
        end
      end

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
