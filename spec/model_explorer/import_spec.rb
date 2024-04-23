require "rails_helper"

RSpec.describe ModelExplorer::Import do
  describe "#import" do
    subject { import.import }

    let(:import) { described_class.new(record_data) }

    let(:record_data) do
      {
        model: "User",
        attributes: user_attributes,
        associations: []
      }
    end

    let(:user_attributes) do
      {id: "1", email: "johndoe@gmail.com"}
    end

    it "creates a new record" do
      expect { subject }.to change(User, :count).by(1)
    end

    context "when the record already exists" do
      before { User.create!(user_attributes) }

      it "does not create a new record" do
        expect { subject }.not_to change(User, :count)
      end
    end

    context "when the record is invalid" do
      let(:record_data) do
        {
          model: "Post",
          attributes: {id: "1"},
          associations: []
        }
      end

      it "raises an error" do
        expect { subject }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when the user has posts" do
      let(:record_data) do
        {
          model: "User",
          attributes: {id: "1", email: "johndoe@gmail.com"},
          associations: [
            {
              name: "posts",
              type: :has_many,
              records: [
                {
                  model: "Post",
                  attributes: {id: "1", title: "Hello", content: "World", user_id: "1"},
                  associations: []
                }
              ]
            },
            {
              name: "first_post",
              type: :has_one,
              records: [
                {
                  model: "Post",
                  attributes: {id: "1", title: "Hello", content: "World", user_id: "1"},
                  associations: []
                }
              ]
            }
          ]
        }
      end

      it "creates a new user with post and wihout duplicate records" do
        subject
        expect(User.count).to eq(1)
        expect(Post.count).to eq(1)
      end
    end
  end
end
