require "rails_helper"

RSpec.describe ModelExplorer::Associations::Singular do
  describe "#export" do
    subject { association.export }

    let(:association) do
      described_class.new(
        post,
        Post.reflect_on_association(:user),
        {name: :user, associations: []}
      )
    end

    let(:user) { User.create!(name: "foo", email: "foo@bar.baz") }
    let(:post) { user.posts.create!(title: "foo", content: "bar") }

    it "returns the association data" do
      expect(subject).to match({
        name: :user,
        type: :belongs_to,
        records: [{
          model: "User",
          attributes: hash_including("name" => "foo", "email" => "foo@bar.baz"),
          associations: []
        }]
      })
    end
  end

  describe "#records" do
    subject { association.records }

    let(:association) do
      described_class.new(
        post,
        Post.reflect_on_association(:user),
        {name: :user, associations: []}
      )
    end

    let(:user) { User.create!(name: "foo", email: "foo@bar.baz") }
    let(:post) { user.posts.create!(title: "foo", content: "bar") }

    it "returns the relation as an array", :aggregate_failures do
      expect(subject).to be_an(Array)
      expect(subject.first).to be_a(ModelExplorer::Record)
      expect(subject.first[:id]).to eq(user.id)
    end
  end
end
