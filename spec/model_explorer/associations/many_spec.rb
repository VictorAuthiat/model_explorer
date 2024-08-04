require "rails_helper"

RSpec.describe ModelExplorer::Associations::Many do
  describe "#export" do
    subject { association.export }

    let(:association) do
      described_class.new(
        user,
        User.reflect_on_association(:posts),
        {name: :posts, associations: []}
      )
    end

    let(:user) { User.create!(name: "foo", email: "foo@bar.baz") }
    let!(:post) { user.posts.create!(title: "foo", content: "bar") }

    it "returns the association data" do
      expect(subject).to match({
        name: :posts,
        type: :has_many,
        scopes: [],
        count: 1,
        records: [{
          model: "Post",
          attributes: hash_including("title" => "foo", "content" => "bar"),
          associations: []
        }]
      })
    end
  end

  describe "#records" do
    subject { association.records }

    let(:association) do
      described_class.new(
        user,
        User.reflect_on_association(:posts),
        {name: :posts, associations: []}
      )
    end

    let(:user) { User.create!(name: "foo", email: "foo@bar.baz") }
    let!(:post) { user.posts.create!(title: "foo", content: "bar") }

    it "returns the an array of records", :aggregate_failures do
      expect(subject).to be_an(Array)
      expect(subject.first).to be_a(ModelExplorer::Record)
      expect(subject.first[:id]).to eq(post.id)
      expect(subject.count).to eq(1)
    end

    context "when the association has an invalid scope" do
      let(:association) do
        described_class.new(
          user,
          User.reflect_on_association(:comments),
          {name: :comments, associations: [], scopes: ["destroy_all"]}
        )
      end

      let(:user) { User.create!(name: "foo", email: "foo@bar.baz") }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError, "Unknown scope destroy_all for Comment")
      end
    end

    context "when the association has scopes" do
      let(:association) do
        described_class.new(
          user,
          User.reflect_on_association(:comments),
          {name: :comments, associations: [], scopes: ["published"]}
        )
      end

      let(:user) { User.create!(name: "foo", email: "foo@bar.baz") }
      let!(:draft_comment) { user.comments.create!(content: "bar", status: "draft", post: post) }
      let!(:published_comment) { user.comments.create!(content: "foo", status: "published", post: post) }

      it "returns the active record relation with the scope applied", :aggregate_failures do
        expect(subject).to be_an(Array)
        expect(subject.first).to be_a(ModelExplorer::Record)
        expect(subject.first[:id]).to eq(published_comment.id)
        expect(subject.count).to eq(1)
      end
    end
  end
end
