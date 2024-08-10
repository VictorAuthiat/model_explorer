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

      def records
        @_records ||=
          klass
          .connection
          .exec_query(query.to_sql)
          .map { |record_attributes| build_record(record_attributes) }
      end

      protected

      def query
        raise NotImplementedError
      end

      def default_query
        klass
          .select(ModelExplorer::Select.new(klass, association[:columns]).to_a)
          .where(reflection_query)
      end

      def build_record(record_attributes)
        attributes =
          if association[:columns].present?
            record_attributes.slice(*association[:columns])
          else
            record_attributes
          end

        ModelExplorer::Record.new(
          record_attributes[klass.primary_key],
          attributes,
          klass
        )
      end

      def reflection_query
        foreign_key = reflection.foreign_key

        case reflection.macro
        when :has_many, :has_one then {foreign_key => record[klass.primary_key]}
        when :belongs_to then {"#{reflection.table_name}.id" => record[klass.primary_key]}
        end
      end

      def export_records
        records.map do |relation_record|
          ModelExplorer::Export.new(
            record: relation_record,
            associations: association[:associations]
          ).data
        end
      end
    end
  end
end
