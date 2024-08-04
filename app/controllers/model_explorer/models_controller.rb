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
        render_not_found("Model '#{model_name}' not found")
      end
    rescue => e
      render_bad_request(e.message)
    end
  end
end
