# frozen_string_literal: true

module ModelExplorer
  class ModelsController < ApplicationController
    def index
      @models = model_names
    end

    def show
      model_name = params[:id]

      if model_names.include?(model_name)
        render json: ModelSerializer.new(
          model: model_name.constantize,
          macro: params[:macro],
          parent: params[:parent]
        ).to_json
      else
        render json: {error: "Model '#{model_name}' not found"}, status: :not_found
      end
    rescue => e
      render json: {error: e.message}, status: :bad_request
    end

    private

    def model_names
      ModelExplorer.models.map(&:name).sort
    end
  end
end
