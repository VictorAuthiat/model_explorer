require "rails_helper"

RSpec.describe "POST /model_explorer/export", type: :request do
  subject do
    post exports_path, params: params
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
      expect(JSON.parse(response.body)["error"]).to be_present
    end
  end

  context "when an unknown error occurs" do
    let(:params) do
      {
        model: "User",
        record_id: 1,
        association_attributes: {}
      }
    end

    before do
      allow(ModelExplorer::Export).to(
        receive(:new).and_raise(StandardError, "Unknown error")
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

    it { is_expected.to have_http_status(:bad_request) }

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

        expect(JSON.parse(response.body)).to match(
          {
            "model" => "User",
            "attributes" => hash_including(
              "name" => "foo",
              "email" => "bar@baz.buz"
            ),
            "associations" => []
          }
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
                  name: "invalid",
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
        expect(JSON.parse(response.body)["error"]).to be_present
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

        expect(JSON.parse(response.body)).to match(
          {
            "model" => "User",
            "attributes" => hash_including(
              "name" => "foo",
              "email" => "bar@baz.buz"
            ),
            "associations" => [
              {
                "name" => "posts",
                "type" => "has_many",
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
      end
    end
  end
end