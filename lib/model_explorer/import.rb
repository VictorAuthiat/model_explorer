module ModelExplorer
  class Import
    attr_reader :json_record

    # @param json_record [String] JSON representation of the record
    def initialize(json_record)
      @json_record = json_record
    end

    # @return [ActiveRecord::Base]
    def import
      record_data = JSON.parse(json_record)

      import_record(record_data)
    end

    private

    def import_record(record_data)
      import_associations_with_macros(record_data, :belongs_to)

      model = record_data["model"].constantize
      record = model.new(record_data["attributes"])

      if defined?(Devise) && model.included_modules.include?(Devise::Models::DatabaseAuthenticatable)
        record.password = "FakePa$$word12345!"
        record.password_confirmation = "FakePa$$word12345!"
      end

      record.save!

      import_associations_with_macros(record_data, :has_many, :has_one)

      record
    end

    def import_associations_with_macros(record_data, *macros)
      macros_associations = record_data["associations"].select do |association|
        record_data["model"]
          .constantize
          .reflect_on_association(association["name"])
          .macro
          .in?(macros)
      end

      macros_associations.each do |association|
        association["records"].each do |record_data|
          import_record(record_data)
        end
      end
    end
  end
end
