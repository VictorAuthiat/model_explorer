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

    private

    def verify_access
      return if ModelExplorer.verify_access_proc.call(self)

      flash[:error] = t("unauthorized", scope: "model_explorer")

      redirect_to "/"
    end
  end
end
