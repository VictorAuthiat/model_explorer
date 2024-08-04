# frozen_string_literal: true

class ModelSerializer < ApplicationSerializer
  attr_reader :model, :macro, :parent

  def initialize(model:, macro:, parent: nil)
    @model = model
    @macro = macro
    @parent = parent
  end

  def to_h
    {
      model: model.name,
      columns: model.column_names,
      scopes: build_scopes,
      associations: build_associations
    }
  end

  private

  def build_scopes
    case macro
    when "has_many"
      model.model_explorer_scopes.map(&:to_s)
    else
      []
    end
  end

  def build_associations
    model.reflect_on_all_associations.filter_map do |association|
      next if association.options[:through] || association.name.to_s == parent

      AssociationSerializer.new(association).to_h
    end
  end
end
