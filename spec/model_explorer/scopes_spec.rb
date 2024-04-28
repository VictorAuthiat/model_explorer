require "rails_helper"

RSpec.describe ModelExplorer::Scopes do
  describe ".model_explorer_scopes" do
    subject { model.model_explorer_scopes }

    context "when the model has no scopes" do
      let(:model) { Class.new(ApplicationRecord) }

      it "returns an empty array" do
        subject
        expect(model.model_explorer_scopes).to eq([])
      end
    end

    context "when the model has a scope" do
      let(:model) do
        Class.new(ApplicationRecord) do
          scope :active, -> { where(active: true) }
        end
      end

      it "returns an array with the scope name" do
        subject
        expect(model.model_explorer_scopes).to eq([:active])
      end
    end

    context "when the model has a scope with arguments" do
      let(:model) do
        Class.new(ApplicationRecord) do
          scope :active, ->(value) { where(active: value) }
        end
      end

      it "does not include the scope" do
        subject
        expect(model.model_explorer_scopes).to eq([])
      end
    end

    context "when there is an almost valid scope" do
      let(:model) do
        Class.new(ApplicationRecord) do
          scope :active, Class.new { attr_reader :call }.new
          scope :inactive, -> { where(active: false) }
        end
      end

      it "does not include the invalid scope" do
        subject
        expect(model.model_explorer_scopes).to eq([:inactive])
      end
    end
  end
end
