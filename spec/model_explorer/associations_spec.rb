require "rails_helper"

RSpec.describe ModelExplorer::Associations do
  describe ".export" do
    subject { described_class.build(record, reflection, association) }

    let(:record) { double }
    let(:reflection) { double(macro: macro) }
    let(:association) { {name: "foo"} }

    context "when macro is has_many" do
      let(:macro) { :has_many }

      it "returns a Many association" do
        expect(subject).to be_a(ModelExplorer::Associations::Many)
      end
    end

    context "when macro is has_one" do
      let(:macro) { :has_one }

      it "returns a Singular association" do
        expect(subject).to be_a(ModelExplorer::Associations::Singular)
      end
    end

    context "when macro is belongs_to" do
      let(:macro) { :belongs_to }

      it "returns a Singular association" do
        expect(subject).to be_a(ModelExplorer::Associations::Singular)
      end
    end

    context "when macro is unknown" do
      let(:macro) { :unknown }

      it "raises an error" do
        expect { subject }.to raise_error("Unknown association foo")
      end
    end
  end
end
