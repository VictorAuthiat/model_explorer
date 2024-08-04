require "rails_helper"

RSpec.describe ModelExplorer::Select do
  describe "#columns" do
    subject { select.columns }

    let(:model) do
      double(
        "model",
        column_names: %w[id name],
        primary_key: "id",
        table_name: "users"
      )
    end

    let(:select) do
      described_class.new(model, selects)
    end

    context "when there are no selects" do
      let(:selects) { [] }

      it { is_expected.to eq(%w[id name]) }
    end

    context "when there are selects" do
      let(:selects) { %w[name] }

      it { is_expected.to eq(%w[id name]) }
    end

    context "when there are no matching columns" do
      let(:selects) { %w[foo] }

      it { is_expected.to eq(["#{model.table_name}.*"]) }
    end

    context "when there are selects with primary key" do
      let(:selects) { %w[id name] }

      it { is_expected.to eq(%w[id name]) }
    end
  end
end
