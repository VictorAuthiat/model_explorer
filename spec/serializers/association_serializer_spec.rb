require "rails_helper"

RSpec.describe AssociationSerializer do
  let(:association) do
    double(
      "association",
      name: "user",
      macro: "has_many",
      class_name: "User"
    )
  end

  let(:serializer) do
    described_class.new(association)
  end

  describe "#to_h" do
    subject { serializer.to_h }

    it "returns the association as a hash" do
      expect(subject).to eq({name: "user", macro: "has_many", model: "User"})
    end
  end
end
