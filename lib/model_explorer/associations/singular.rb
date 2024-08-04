module ModelExplorer
  module Associations
    class Singular < Base
      def export
        {
          name: name,
          type: macro,
          records: export_records
        }
      end

      private

      def query
        default_query.limit(1)
      end
    end
  end
end
