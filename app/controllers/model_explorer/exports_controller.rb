# frozen_string_literal: true

module ModelExplorer
  class ExportsController < ApplicationController
    # Warning: all parameters are permitted.
    # Associations must not be called directly on the record.
    def show
      ensure_valid_model_name(params[:model])

      render_export
    rescue => error
      render_bad_request(error)
    end

    private

    def render_export
      render json: {
        export: build_export,
        path: exports_path(params.except(:controller, :action))
      }.to_json
    rescue ActiveRecord::RecordNotFound => error
      render_not_found(error)
    end

    def build_export
      export = ModelExplorer::Export.new(
        record: build_record(params[:model].constantize),
        associations: ModelExplorer::Associations.build_from_params(params.permit!.to_h)
      )

      export.data
    end

    def build_record(model)
      select = ModelExplorer::Select.new(model, params[:columns]).to_a
      record = model.select(select).find(params[:record_id])

      attributes =
        if params[:columns].present?
          record.attributes.slice(*params[:columns])
        else
          record.attributes
        end

      ModelExplorer::Record.new(
        record.attributes[model.primary_key],
        attributes,
        model
      )
    end
  end
end
