# frozen_string_literal: true

class ModelSerializer < ApplicationSerializer
  attr_reader :model, :macro

  def initialize(model:, macro:)
    @model = model
    @macro = macro
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
      next if association.options[:through]

      AssociationSerializer.new(association).to_h
    end
  end
end
