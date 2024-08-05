require "rails_helper"

RSpec.describe "GET /model_explorer/models", type: :request do
  subject do
    get models_path
    response
  end

  it { is_expected.to have_http_status(:success) }
end

RSpec.describe "GET /model_explorer/models/:id", type: :request do
  subject do
    get model_path(model, macro: macro, parent: parent)
    response
  end

  let(:json_response) do
    JSON.parse(subject.body)
  end

  let(:model) { "User" }
  let(:macro) { nil }
  let(:parent) { nil }

  it { is_expected.to have_http_status(:success) }

  it "constructs a ModelSerializer with the correct arguments" do
    expect(ModelSerializer).to receive(:new).with(
      model: User,
      macro: nil,
      parent: nil
    ).and_call_original

    subject
  end

  it "includes the model and associations in the response" do
    expect(json_response).to include("model", "associations")
  end

  it "returns the model name" do
    expect(json_response["model"]).to eq(model)
  end

  it "returns the model associations" do
    expect(json_response["associations"]).to include(
      {"model" => "Post", "name" => "posts", "macro" => "has_many"},
      {"model" => "Post", "name" => "first_post", "macro" => "has_one"},
      {"model" => "Comment", "name" => "comments", "macro" => "has_many"}
    )
  end

  context "when the model has a parent and macro" do
    let(:model) { "Post" }
    let(:macro) { "has_many" }
    let(:parent) { "user" }

    it "constructs a ModelSerializer with the correct arguments" do
      expect(ModelSerializer).to receive(:new).with(
        model: Post,
        macro: "has_many",
        parent: "user"
      ).and_call_original

      subject
    end

    it "returns the model name" do
      expect(json_response["model"]).to eq(model)
    end

    it "returns the model associations" do
      expect(json_response["associations"]).to include(
        {"model" => "Comment", "name" => "comments", "macro" => "has_many"}
      )
    end
  end

  context "when the model does not exist" do
    let(:model) { "Unknown" }

    it { is_expected.to have_http_status(:bad_request) }

    it "returns an error message" do
      expect(json_response["error"]).to eq("Model 'Unknown' not found")
    end
  end

  context "when the model raises an error" do
    before do
      allow(ModelSerializer).to receive(:new).and_raise("Error")
    end

    it { is_expected.to have_http_status(:bad_request) }

    it "returns an error message" do
      expect(json_response["error"]).to eq("Error")
    end
  end
end
