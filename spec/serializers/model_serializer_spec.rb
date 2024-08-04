require "rails_helper"

RSpec.describe ModelSerializer do
  describe "#to_h" do
    subject { serializer.to_h }

    let(:serializer) do
      described_class.new(model: model, macro: macro)
    end

    context "when the model has associations" do
      let(:model) { User }
      let(:macro) { nil }

      it "returns the model as a hash" do
        expect([subject]).to include(
          hash_including(
            associations: [
              {
                macro: :has_many,
                model: "Post",
                name: :posts
              },
              {
                macro: :has_many,
                model: "Comment",
                name: :comments
              },
              {
                macro: :has_one,
                model: "Post",
                name: :first_post
              }
            ],
            columns: array_including("id", "email", "created_at", "updated_at"),
            model: "User",
            scopes: []
          )
        )
      end
    end

    context "when the model has scopes" do
      let(:model) { Comment }
      let(:macro) { "has_many" }

      it "returns the model as a hash" do
        expect([subject]).to include(
          hash_including(
            associations: [
              {
                macro: :belongs_to,
                model: "Post",
                name: :post
              },
              {
                macro: :belongs_to,
                model: "User",
                name: :user
              }
            ],
            columns: array_including("id", "content", "status", "post_id", "user_id", "created_at", "updated_at"),
            model: "Comment",
            scopes: array_including("draft", "published", "archived")
          )
        )
      end
    end
  end
end
