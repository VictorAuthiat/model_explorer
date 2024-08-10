module ModelExplorer
  class Record
    attr_reader :primary_key, :attributes, :klass

    def initialize(primary_key, attributes, klass)
      @primary_key = primary_key
      @attributes = attributes.with_indifferent_access
      @klass = klass
    end

    def [](key)
      attributes[key.to_s]
    end
  end
end
