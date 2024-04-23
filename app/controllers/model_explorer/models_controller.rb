# frozen_string_literal: true

module ModelExplorer
  class ModelsController < ApplicationController
    def index
      @models = fetch_models.map(&:name).sort
    end

    def show
      model = params[:id].constantize

      render json: {model: model.name, associations: build_associations(model)}
    rescue NameError
      render json: {model: params[:id], associations: []}
    end

    private

    def fetch_models
      load_models_if_needed

      ActiveRecord::Base.descendants.reject do |descendant|
        descendant.name.match(/HABTM/) || descendant.abstract_class?
      end
    end

    def load_models_if_needed
      return if ActiveRecord::Base.descendants.any?

      ActiveRecord.eager_load!
    end

    def build_associations(model)
      model.reflect_on_all_associations.map do |association|
        {
          name: association.name,
          model: association.class_name || association.name.classify
        }
      end
    end
  end
end
