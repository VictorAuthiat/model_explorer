require "rails_helper"

RSpec.describe ModelExplorer::Associations::Base do
  let(:base_association) do
    described_class.new(
      double("record"),
      double("reflection", klass: User),
      double("association")
    )
  end

  describe "#export" do
    subject { base_association.export }

    it "raises an error" do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe "#records" do
    subject { base_association.records }

    it "raises an error" do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end
end
