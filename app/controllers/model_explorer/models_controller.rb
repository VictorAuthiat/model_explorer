# frozen_string_literal: true

module ModelExplorer
  class ModelsController < ApplicationController
    def index
      @models = ModelExplorer.models.map(&:name).sort
    end

    def show
      render json: ModelSerializer.new(
        model: params[:id].constantize,
        macro: params[:macro]
      ).to_json
    rescue => e
      render json: {error: e.message}, status: :bad_request
    end
  end
end
