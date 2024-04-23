module ModelExplorer
  class Import
    FAKE_PASSWORD = "FakePa$$word12345!"

    attr_reader :record_data
    attr_reader :record
    attr_reader :model

    # @param record_data [String] JSON representation of the record
    def initialize(record_data)
      @record_data = record_data
      @record = nil
      @model = nil
    end

    # @return [ActiveRecord::Base]
    def import
      @model = record_data[:model].constantize
      @record = model.find_or_initialize_by(record_data[:attributes])

      create_record_with_associations!

      record
    end

    private

    def create_record_with_associations!
      ActiveRecord::Base.transaction do
        import_associations_with_macros(:belongs_to)
        set_devise_password if defined?(Devise)
        record.save!
        import_associations_with_macros(:has_many, :has_one)
      end
    end

    def import_associations_with_macros(*macros)
      with_macros_associations(macros) do |association|
        import_records(association)
      end
    end

    def with_macros_associations(macros)
      record_data[:associations].each do |association|
        next unless model.reflect_on_association(association[:name]).macro.in?(macros)

        yield association
      end
    end

    def import_records(association)
      association[:records].each do |record_data|
        self.class.new(record_data).import
      end
    end

    def set_devise_password
      return unless model.included_modules.include?(Devise::Models::DatabaseAuthenticatable)

      record.password = FAKE_PASSWORD
      record.password_confirmation = FAKE_PASSWORD
    end
  end
end
