module ModelExplorer
  class Export
    attr_reader :record
    attr_reader :associations

    # @param record [ActiveRecord::Base] Record to export
    # @param associations [Array<Hash>] List of associations
    def initialize(record:, associations: [])
      @record = record
      @associations = associations
      @data = nil
    end

    def to_json(*)
      data.to_json
    end

    def data
      @data ||= {
        model: record.class.name,
        attributes: filtered_attributes,
        associations: record_associations
      }
    end

    private

    def filtered_attributes
      record.attributes.to_h do |key, value|
        filtered_value =
          if key.to_s.match?(ModelExplorer.configuration.filter_attributes_regexp)
            "---FILTERED---"
          else
            value
          end

        [key, filtered_value]
      end
    end

    def record_associations
      associations.map do |association|
        {
          name: association[:name],
          type: record.class.reflect_on_association(association[:name]).macro,
          records: build_association_export(association)
        }
      end
    end

    def build_association_export(association)
      relation = record.public_send(association[:name])

      case relation
      when ActiveRecord::Base
        build_export(association, [relation])
      when ActiveRecord::Relation
        build_export(association, relation)
      end
    end

    def build_export(association, relation)
      relation.map do |relation_record|
        ModelExplorer::Export.new(
          record: relation_record,
          associations: association[:associations]
        ).data
      end
    end
  end
end
