# frozen_string_literal: true

module ModelExplorer
  class ApplicationController < ActionController::Base
    layout "model_explorer/application"

    before_action :verify_access

    http_basic_authenticate_with(
      name: ModelExplorer.basic_auth_username.to_s,
      password: ModelExplorer.basic_auth_password.to_s,
      if: -> { ModelExplorer.basic_auth_enabled }
    )

    protected

    def render_not_found(error)
      render json: {error: error.message}, status: :not_found
    end

    def render_bad_request(error)
      render json: {error: error.message}, status: :bad_request
    end

    def ensure_valid_model_name(model_name = nil)
      return if ModelExplorer.models.map(&:name).include?(model_name)

      raise "Model '#{model_name}' not found"
    end

    private

    def verify_access
      return if ModelExplorer.verify_access_proc.call(self)

      flash[:error] = t("unauthorized", scope: "model_explorer")

      redirect_to "/"
    end
  end
end
