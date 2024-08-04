require "rails_helper"

RSpec.describe ApplicationSerializer do
  let(:serializer) { described_class.new }

  describe "#to_h" do
    subject { serializer.to_h }

    it "raises a NotImplementedError" do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe "#to_json" do
    subject { serializer.to_json }

    before do
      allow(serializer).to receive(:to_h).and_return({})
    end

    it "returns the serialized object as JSON" do
      expect(serializer.to_json).to eq("{}")
    end
  end
end
