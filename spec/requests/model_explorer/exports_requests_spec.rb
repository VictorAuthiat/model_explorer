require "rails_helper"

RSpec.describe "GET /model_explorer/export", type: :request do
  subject do
    get exports_path, params: params
    response
  end

  context "when the model does not exist" do
    let(:params) do
      {
        model: "Unknown",
        record_id: 1,
        association_attributes: {}
      }
    end

    it { is_expected.to have_http_status(:bad_request) }

    it "returns an error message" do
      subject
      expect(JSON.parse(response.body)["error"]).to eq("Model 'Unknown' not found")
    end
  end

  context "when model class exist but is not an ApplicationRecord model" do
    let(:params) do
      {
        model: "RailsApp::Application",
        record_id: 1,
        association_attributes: {}
      }
    end

    it { is_expected.to have_http_status(:bad_request) }

    it "returns an error message" do
      subject
      expect(JSON.parse(response.body)["error"]).to eq("Model 'RailsApp::Application' not found")
    end
  end

  context "when an unknown error occurs" do
    let(:params) do
      {
        model: "User",
        record_id: user.id,
        association_attributes: {}
      }
    end

    before do
      allow(ModelExplorer::Export).to(
        receive(:new).and_raise(StandardError, "Unknown error")
      )
    end

    let!(:user) do
      User.create!(
        name: "foo",
        email: "bar@baz.buz",
        posts: [Post.new(title: "foo", content: "bar")]
      )
    end

    it { is_expected.to have_http_status(:bad_request) }

    it "returns an error message" do
      subject
      expect(JSON.parse(response.body)["error"]).to be_present
    end
  end

  context "when the model exists but record does not" do
    let(:params) do
      {
        model: "User",
        record_id: 1,
        association_attributes: {}
      }
    end

    it { is_expected.to have_http_status(:not_found) }

    it "returns an error message" do
      subject
      expect(JSON.parse(response.body)["error"]).to be_present
    end
  end

  context "when the model exists and record too" do
    let!(:user) do
      User.create!(
        name: "foo",
        email: "bar@baz.buz",
        posts: [Post.new(title: "foo", content: "bar")]
      )
    end

    context "when no associations are passed" do
      let(:params) do
        {
          model: "User",
          record_id: 1,
          association_attributes: {}
        }
      end

      it { is_expected.to have_http_status(:success) }

      it "returns the user export without associations" do
        subject

        expect([JSON.parse(response.body)]).to include(
          hash_including(
            "export" => {
              "model" => "User",
              "attributes" => hash_including(
                "id" => 1,
                "name" => "foo",
                "email" => "bar@baz.buz",
                "encrypted_password" => "---FILTERED---"
              ),
              "associations" => []
            }
          )
        )
      end
    end

    context "when invalid associations are passed" do
      let(:params) do
        {
          model: "User",
          record_id: 1,
          association_attributes: {
            associations: {
              "0" => {
                association_attributes: {
                  name: "destroy",
                  associations: {}
                }
              }
            }
          }
        }
      end

      it { is_expected.to have_http_status(:bad_request) }

      it "returns an error message" do
        subject
        expect(JSON.parse(response.body)["error"]).to eq("Unknown association destroy")
      end

      it "does not destroy the user" do
        expect { subject }.not_to change(User, :count)
      end
    end

    context "when valid associations are passed" do
      let(:params) do
        {
          model: "User",
          record_id: 1,
          association_attributes: {
            associations: {
              "0" => {
                association_attributes: {
                  name: "posts",
                  associations: {}
                }
              }
            }
          }
        }
      end

      it { is_expected.to have_http_status(:success) }

      it "returns the user export with associations" do
        subject

        expect([JSON.parse(response.body)]).to include(
          hash_including(
            "export" => {
              "model" => "User",
              "attributes" => hash_including(
                "id" => 1,
                "name" => "foo",
                "email" => "bar@baz.buz",
                "encrypted_password" => "---FILTERED---"
              ),
              "associations" => [
                {
                  "name" => "posts",
                  "type" => "has_many",
                  "scopes" => [],
                  "count" => 1,
                  "records" => [
                    {
                      "model" => "Post",
                      "attributes" => hash_including(
                        "title" => "foo",
                        "content" => "bar"
                      ),
                      "associations" => []
                    }
                  ]
                }
              ]
            }
          )
        )
      end
    end
  end
end
