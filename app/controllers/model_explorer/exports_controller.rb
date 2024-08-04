# frozen_string_literal: true

module ModelExplorer
  class ExportsController < ApplicationController
    # Warning: all parameters are permitted.
    # Associations must not be called directly on the record.
    def create
      model = params[:model].constantize

      render json: ModelExplorer::Export.new(
        record: build_record(model),
        associations: ModelExplorer::Associations.build_from_params(params.permit!.to_h)
      )
    rescue => e
      render json: {error: e.message}, status: :bad_request
    end

    private

    def build_record(model)
      select = ModelExplorer::Select.new(model, params[:columns]).to_a
      record = model.select(select).find(params[:record_id])

      ModelExplorer::Record.new(record.attributes, model)
    end
  end
end
