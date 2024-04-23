require "rails_helper"

RSpec.describe "GET /model_explorer/models", type: :request do
  subject do
    get models_path
    response
  end

  # test eager loading
  context "when the models are not loaded" do
    before do
      allow(ActiveRecord::Base).to receive(:descendants).and_return([])
    end

    after do
      allow(ActiveRecord::Base).to receive(:descendants).and_call_original
    end

    it "loads the models" do
      expect(ActiveRecord).to receive(:eager_load!)
      subject
    end

    it { is_expected.to have_http_status(:success) }
  end

  context "when the models are loaded" do
    before do
      allow(ActiveRecord::Base).to receive(:descendants).and_return([User, Post, Comment])
    end

    after do
      allow(ActiveRecord::Base).to receive(:descendants).and_call_original
    end

    it "does not load the models" do
      expect(ActiveRecord).not_to receive(:eager_load!)
      subject
    end

    it { is_expected.to have_http_status(:success) }
  end
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
      {"model" => "Post", "name" => "posts"},
      {"model" => "Post", "name" => "first_post"},
      {"model" => "Comment", "name" => "comments"}
    )
  end

  context "when the model does not exist" do
    let(:model) { "Unknown" }

    it "returns an empty array of associations" do
      expect(subject["model"]).to eq(model)
      expect(subject["associations"]).to eq([])
    end
  end
end
