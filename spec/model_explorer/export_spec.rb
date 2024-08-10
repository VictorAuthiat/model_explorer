require "rails_helper"

RSpec.describe ModelExplorer::Export do
  describe "#initialize" do
    subject { export }

    let(:export) { described_class.new(record: user, associations: associations) }
    let(:user) { ModelExplorer::Record.new(1, {email: "foo@bar.baz", password: "password"}, User) }
    let(:associations) { [{name: "posts", associations: []}] }

    it "initializes with a record and optional associations", :aggregate_failures do
      expect(subject.record).to eq(user)
      expect(subject.associations).to eq(associations)
    end

    context "when record is not a valid ActiveRecord model" do
      let(:user) { double(:user) }

      it "raises an error" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#to_json" do
    subject { export.to_json }

    before { allow(export).to receive(:data).and_return(fake_data) }

    let(:export) do
      described_class.new(
        record: ModelExplorer::Record.new(1, {}, User),
        associations: []
      )
    end

    let(:fake_data) { {foo: "bar"} }

    it "returns data as a JSON formatted string" do
      expect(subject).to eq(fake_data.to_json)
    end
  end

  describe "#data" do
    subject { export.data }

    let(:export) do
      described_class.new(
        record: user,
        associations: [{name: "posts", associations: []}]
      )
    end

    let(:user) do
      db_user = User.create!(email: "foo@bar.baz", password: "password")

      ModelExplorer::Record.new(db_user.id, db_user.attributes, User)
    end

    it "returns a JSON formatted string of the export data" do
      expect(subject).to match({
        model: "User",
        attributes: hash_including("email" => "foo@bar.baz", "encrypted_password" => "---FILTERED---"),
        associations: [
          {
            name: :posts,
            type: :has_many,
            scopes: [],
            records: [],
            count: 0
          }
        ]
      })
    end

    context "when custom filter attributes regexp is set" do
      around do |example|
        default_regexp = ModelExplorer.filter_attributes_regexp
        ModelExplorer.filter_attributes_regexp = /email/
        example.run
        ModelExplorer.filter_attributes_regexp = default_regexp
      end

      it "filters the attributes based on the regexp" do
        expect(subject[:attributes]).to include("email" => "---FILTERED---")
      end
    end

    context "when the record has associations and they are included in the export" do
      before do
        Post.create!(user_id: user[:id], title: "foo", content: "bar")
      end

      let(:export) do
        described_class.new(
          record: user,
          associations: [
            {name: :posts, associations: []},
            {name: :first_post, associations: []}
          ]
        )
      end

      it "returns a JSON formatted string of the export data" do
        expect(subject).to match({
          model: "User",
          attributes: hash_including("email" => user["email"], "encrypted_password" => "---FILTERED---"),
          associations: [
            {
              name: :posts,
              type: :has_many,
              scopes: [],
              count: 1,
              records: [{
                model: "Post",
                attributes: hash_including("title" => "foo", "content" => "bar"),
                associations: []
              }]
            },
            {
              name: :first_post,
              type: :has_one,
              records: [{
                model: "Post",
                attributes: hash_including("title" => "foo", "content" => "bar"),
                associations: []
              }]
            }
          ]
        })
      end

      context "and the association has scopes" do
        let(:export) do
          described_class.new(
            record: user,
            associations: [
              {
                name: :comments,
                scopes: ["published"],
                associations: [
                  {
                    name: :post,
                    associations: [],
                    scopes: []
                  }
                ]
              }
            ]
          )
        end

        before do
          post = Post.create!(user_id: user[:id], title: "foo", content: "bar")
          Comment.create!(user_id: user[:id], content: "baz", status: :draft, post: post)
          Comment.create!(user_id: user[:id], content: "baz", status: :published, post: post)
        end

        it "returns a JSON formatted string of the export data with the scoped records" do
          expect(subject).to match({
            model: "User",
            attributes: hash_including("email" => user[:email], "encrypted_password" => "---FILTERED---"),
            associations: [
              {
                name: :comments,
                type: :has_many,
                count: 1,
                scopes: ["published"],
                records: [
                  {
                    model: "Comment",
                    attributes: hash_including("content" => "baz", "status" => 1),
                    associations: [
                      {
                        name: :post,
                        type: :belongs_to,
                        records: [
                          {
                            model: "Post",
                            attributes: hash_including("title" => "foo", "content" => "bar"),
                            associations: []
                          }
                        ]
                      }
                    ]
                  }
                ]
              }
            ]
          })
        end
      end

      context "and the association has invalid scopes" do
        let(:export) do
          described_class.new(
            record: user,
            associations: [
              {
                name: :comments,
                scopes: ["destroy_all"],
                associations: []
              }
            ]
          )
        end

        before do
          post = Post.create!(user_id: user[:id], title: "foo", content: "bar")
          Comment.create!(user_id: user[:id], content: "baz", status: :draft, post: post)
          Comment.create!(user_id: user[:id], content: "baz", status: :published, post: post)
        end

        it "raises an ArgumentError" do
          expect { subject }.to raise_error(ArgumentError, "Unknown scope destroy_all for Comment")
        end
      end
    end

    context "when the record has associations but they are not included in the export" do
      before do
        Post.create!(user_id: user[:id], title: "foo", content: "bar")
      end

      let(:export) do
        described_class.new(
          record: user,
          associations: []
        )
      end

      it "returns a JSON formatted string of the export data" do
        expect(subject).to match({
          model: "User",
          attributes: hash_including("email" => user[:email], "encrypted_password" => "---FILTERED---"),
          associations: []
        })
      end
    end
  end
end
