module ModelExplorer
  module Associations
    class Base
      extend Forwardable

      def_delegators :reflection, :name, :macro, :klass

      attr_reader :record, :reflection, :association

      def initialize(record, reflection, association)
        @record = record
        @reflection = reflection
        @association = association
      end

      def export
        raise NotImplementedError
      end

      def relation
        raise NotImplementedError
      end

      protected

      def default_relation
        record.public_send(name)
      end

      def export_records
        relation.map do |relation_record|
          ModelExplorer::Export.new(
            record: relation_record,
            associations: association[:associations]
          ).data
        end
      end
    end
  end
end
