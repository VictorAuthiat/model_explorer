module ModelExplorer
  class Select
    attr_reader :model, :selects

    def initialize(model, selects)
      @model = model
      @selects = selects
    end

    def columns
      column_names = model.column_names

      return column_names if selects.blank?

      selected_columns = column_names & selects

      if selected_columns.empty?
        ["#{model.table_name}.*"]
      else
        ([model.primary_key] + selected_columns).uniq
      end
    end

    def to_a
      columns.map { |column| "#{model.table_name}.#{column}" }
    end
  end
end
