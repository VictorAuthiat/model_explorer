# frozen_string_literal: true

module ModelExplorer
  class ExportsController < ApplicationController
    # Warning: all parameters are permitted.
    # Associations must not be called directly on the record.
    def show
      model_name = params[:model]

      if model_names.include?(model_name)
        export = ModelExplorer::Export.new(
          record: build_record(model_name.constantize),
          associations: ModelExplorer::Associations.build_from_params(params.permit!.to_h)
        )

        render json: {
          export: export.data,
          path: exports_path(params.except(:controller, :action))
        }.to_json
      else
        render_bad_request("Model '#{model_name}' not found")
      end
    rescue ActiveRecord::RecordNotFound => e
      render_not_found(e.message)
    rescue => e
      render_bad_request(e.message)
    end

    private

    def build_record(model)
      select = ModelExplorer::Select.new(model, params[:columns]).to_a
      record = model.select(select).find(params[:record_id])

      ModelExplorer::Record.new(record.attributes, model)
    end
  end
end
