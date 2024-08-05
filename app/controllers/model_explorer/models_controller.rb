# frozen_string_literal: true

module ModelExplorer
  class ModelsController < ApplicationController
    def index
      @models = ModelExplorer.models.map(&:name).sort
    end

    def show
      model_name = params[:id]

      ensure_valid_model_name(model_name)

      render json: ModelSerializer.new(
        model: model_name.constantize,
        macro: params[:macro],
        parent: params[:parent]
      ).to_json
    rescue => error
      render_bad_request(error)
    end
  end
end
