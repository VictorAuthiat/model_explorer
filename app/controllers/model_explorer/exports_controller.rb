# frozen_string_literal: true

module ModelExplorer
  class ExportsController < ApplicationController
    # Warning: all parameters are permitted.
    # Associations must not be called directly on the record.
    def create
      record = params[:model].constantize.find(params[:record_id])
      associations = build_associations(params.permit!.to_h)

      render json: ModelExplorer::Export.new(record: record, associations: associations)
    rescue => e
      render json: {error: e.message}, status: :bad_request
    end

    private

    def build_associations(associations_params)
      associations = associations_params.dig("association_attributes", "associations") || {}

      associations.map do |_index, association_params|
        {
          name: association_params["association_attributes"]["name"],
          associations: build_associations(association_params)
        }
      end
    end
  end
end
