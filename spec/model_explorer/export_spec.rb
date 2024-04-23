require "rails_helper"

RSpec.describe ModelExplorer::Export do
  describe "#initialize" do
    subject { export }

    let(:export) { described_class.new(record: user, associations: associations) }
    let(:user) { User.create!(email: "foo@bar.baz", password: "password") }
    let(:associations) { [{name: "posts", associations: []}] }

    it "initializes with a record and optional associations", :aggregate_failures do
      expect(subject.record).to eq(user)
      expect(subject.associations).to eq(associations)
    end
  end

  describe "#to_json" do
    subject { export.to_json }

    before { allow(export).to receive(:data).and_return(fake_data) }

    let(:export) { described_class.new(record: User.new) }
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
      User.create!(email: "foo@bar.baz", password: "password")
    end

    it "returns a JSON formatted string of the export data" do
      expect(subject).to match({
        model: "User",
        attributes: hash_including("email" => user.email, "encrypted_password" => "---FILTERED---"),
        associations: [{name: "posts", type: :has_many, records: []}]
      })
    end

    context "with custom filter attributes regexp" do
      around do |example|
        default_regexp = ModelExplorer.configuration.filter_attributes_regexp
        ModelExplorer.configuration.filter_attributes_regexp = /email/
        example.run
        ModelExplorer.configuration.filter_attributes_regexp = default_regexp
      end

      it "filters the attributes based on the regexp" do
        expect(subject[:attributes]).to include("email" => "---FILTERED---")
      end
    end
  end
end
