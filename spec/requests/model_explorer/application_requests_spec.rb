require "rails_helper"

RSpec.describe ModelExplorer::ApplicationController, type: :request do
  describe "HTTP Basic Authentication" do
    subject { get "/model_explorer", headers: headers }

    around do |example|
      ModelExplorer.basic_auth_enabled = basic_auth_enabled
      ModelExplorer.basic_auth_username = "admin"
      ModelExplorer.basic_auth_password = "password"
      example.run
      ModelExplorer.basic_auth_enabled = false
    end

    let(:headers) { {"HTTP_AUTHORIZATION" => credentials} }
    let(:credentials) { nil }

    context "when basic auth is enabled" do
      let(:basic_auth_enabled) { true }

      let(:credentials) do
        ActionController::HttpAuthentication::Basic.encode_credentials(
          basic_auth_username,
          basic_auth_password
        )
      end

      context "and the credentials are correct" do
        let(:basic_auth_username) { "admin" }
        let(:basic_auth_password) { "password" }

        it "grants access with correct credentials" do
          subject
          expect(response).to have_http_status(:ok)
        end
      end

      context "and the credentials are incorrect" do
        let(:basic_auth_username) { "admin" }
        let(:basic_auth_password) { "wrong_password" }

        it "denies access with incorrect credentials" do
          subject
          expect(response).to have_http_status(:unauthorized)
        end
      end
    end

    context "when basic auth is disabled" do
      let(:basic_auth_enabled) { false }

      it "grants access without authentication" do
        subject
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "Custom Access Verification" do
    subject { get "/model_explorer" }

    context "when access is granted" do
      before do
        ModelExplorer.verify_access_proc = ->(_controller) { true }
      end

      it "allows access" do
        subject
        expect(response).to have_http_status(:ok)
      end
    end

    context "when access is denied" do
      around do |example|
        ModelExplorer.verify_access_proc = ->(_controller) { false }
        example.run
        ModelExplorer.verify_access_proc = ->(_controller) { true }
      end

      it "redirects to the root path with flash error", :aggregate_failures do
        subject
        expect(response).to redirect_to("/")
        expect(flash[:error]).to be_present
        expect(flash[:error]).not_to match(/translation missing/i)
      end
    end
  end
end
