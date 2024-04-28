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

      unless record.is_a?(ApplicationRecord)
        raise ArgumentError, "Record must be an ActiveRecord model"
      end
    end

    def to_json(*)
      data.to_json
    end

    def data
      @data ||= {
        model: record.class.name,
        attributes: filtered_attributes,
        associations: fetch_associations
      }
    end

    private

    def filtered_attributes
      record.attributes.to_h do |key, value|
        filtered_value =
          if key.to_s.match?(ModelExplorer.filter_attributes_regexp)
            "---FILTERED---"
          else
            value
          end

        [key, filtered_value]
      end
    end

    def fetch_associations
      associations.map do |association|
        reflection = record.class.reflect_on_association(association[:name])

        ModelExplorer::Associations.build(record, reflection, association).export
      end
    end
  end
end
