# frozen_string_literal: true

RSpec.describe ModelExplorer do
  it "has a version number" do
    expect(ModelExplorer::VERSION).not_to be nil
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
end
