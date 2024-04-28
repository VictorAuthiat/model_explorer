# frozen_string_literal: true

module ModelExplorer
  class ModelsController < ApplicationController
    def index
      @models = fetch_models.map(&:name).sort
    end

    def show
      model = params[:id].constantize
      macro = params[:macro]

      render json: {
        model: model.name,
        scopes: build_scopes(model, macro),
        associations: build_associations(model)
      }
    rescue => error
      render json: {error: error.message}, status: :bad_request
    end

    private

    def fetch_models
      ApplicationRecord.descendants.reject do |descendant|
        descendant_name = descendant.name

        descendant_name.blank? ||
          descendant_name.match(/HABTM/) ||
          descendant.abstract_class?
      end
    end

    def build_associations(model)
      model.reflect_on_all_associations.map do |association|
        association_name = association.name

        {
          name: association_name,
          macro: association.macro,
          model: association.class_name || association_name.classify
        }
      end
    end

    def build_scopes(model, macro)
      case macro
      when "has_many"
        model.model_explorer_scopes.map(&:to_s)
      else
        []
      end
    end
  end
end
