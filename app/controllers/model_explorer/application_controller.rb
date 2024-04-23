# frozen_string_literal: true

module ModelExplorer
  class ApplicationController < ActionController::Base
    layout "model_explorer/application"

    before_action :verify_access

    http_basic_authenticate_with(
      name: ModelExplorer.configuration.basic_auth_username,
      password: ModelExplorer.configuration.basic_auth_password,
      if: :basic_auth_enabled?
    )

    private

    def verify_access
      return if ModelExplorer.configuration.verify_access_proc.call(self)

      flash[:error] = t("unauthorized", scope: "model_explorer")

      redirect_to "/"
    end

    def basic_auth_enabled?
      ModelExplorer.configuration.basic_auth_enabled?
    end
  end
end
