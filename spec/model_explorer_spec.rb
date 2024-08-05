# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModelExplorer do
  it "has a version number" do
    expect(ModelExplorer::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields self" do
      expect { |b| described_class.configure(&b) }.to(
        yield_with_args(described_class)
      )
    end
  end

  describe ".import" do
    subject { described_class.import(json_record) }

    let(:json_record) do
      {
        model: "User",
        attributes: {id: 1, email: "foo@bar.baz"},
        associations: []
      }.to_json
    end

    let(:fake_import) { double(:import, import: nil) }

    it "builds an import with the given JSON record" do
      expect(ModelExplorer::Import).to(
        receive(:new)
          .with(JSON.parse(json_record))
          .and_return(fake_import)
      )

      expect(fake_import).to receive(:import)

      subject
    end

    context "when the JSON record is invalid" do
      let(:json_record) { "invalid" }

      it "raises an error" do
        expect { subject }.to raise_error(JSON::ParserError)
      end
    end
  end

  describe ".models" do
    subject { described_class.models }

    it "returns all ApplicationRecord descendants" do
      expect(subject).to eq([User, Post, Comment])
    end

    it "excludes abstract classes" do
      expect(subject).not_to include(ApplicationRecord)
    end
  end

  describe ".association_select_enabled?" do
    subject { described_class.association_select_enabled? }

    context "when max_items_per_association is positive" do
      around do |example|
        default = ModelExplorer.max_items_per_association
        ModelExplorer.max_items_per_association = 1
        example.run
        ModelExplorer.max_items_per_association = default
      end

      it { is_expected.to eq(true) }
    end

    context "when max_items_per_association is zero" do
      around do |example|
        default = ModelExplorer.max_items_per_association
        ModelExplorer.max_items_per_association = 0
        example.run
        ModelExplorer.max_items_per_association = default
      end

      it { is_expected.to eq(false) }
    end
  end

  describe ".association_scopes_enabled?" do
    subject { described_class.association_scopes_enabled? }

    context "when max_scopes_per_association is positive" do
      around do |example|
        default = ModelExplorer.max_scopes_per_association
        ModelExplorer.max_scopes_per_association = 1
        example.run
        ModelExplorer.max_scopes_per_association = default
      end

      it { is_expected.to eq(true) }
    end

    context "when max_scopes_per_association is zero" do
      around do |example|
        default = ModelExplorer.max_scopes_per_association
        ModelExplorer.max_scopes_per_association = 0
        example.run
        ModelExplorer.max_scopes_per_association = default
      end

      it { is_expected.to eq(false) }
    end
  end
end
