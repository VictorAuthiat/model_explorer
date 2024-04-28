require "rails_helper"

RSpec.describe ModelExplorer::Associations::Base do
  let(:association) { described_class.new(double, double, double) }

  describe "build" do
    subject { association.export }

    it "raises an error" do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end

  describe "relation" do
    subject { association.relation }

    it "raises an error" do
      expect { subject }.to raise_error(NotImplementedError)
    end
  end
end
