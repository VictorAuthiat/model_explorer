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
    get model_path(model)
    JSON.parse(response.body)
  end

  let(:model) { "User" }

  it "returns the model name" do
    expect(subject["model"]).to eq(model)
  end

  it "returns the model associations" do
    expect(subject["associations"]).to include(
      {"model" => "Post", "name" => "posts", "macro" => "has_many"},
      {"model" => "Post", "name" => "first_post", "macro" => "has_one"},
      {"model" => "Comment", "name" => "comments", "macro" => "has_many"}
    )
  end

  context "when the model does not exist" do
    let(:model) { "Unknown" }

    it "returns an error message" do
      expect(subject["error"]).to be_present
    end
  end
end
