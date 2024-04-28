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

      def relation
        [default_relation].compact
      end
    end
  end
end
