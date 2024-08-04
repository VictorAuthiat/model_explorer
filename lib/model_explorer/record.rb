module ModelExplorer
  class Record
    attr_reader :attributes, :klass

    def initialize(attributes, klass)
      @attributes = attributes.with_indifferent_access
      @klass = klass
    end

    def [](key)
      attributes[key.to_s]
    end
  end
end
