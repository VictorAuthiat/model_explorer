require "rails_helper"
require "generators/model_explorer/install_generator"

RSpec.describe ModelExplorer::InstallGenerator, type: :generator do
  destination File.expand_path("../../../tmp", __dir__)

  before do
    prepare_destination
    FileUtils.mkdir_p(File.join(destination_root, "config/initializers"))
    File.write(File.join(destination_root, "config/routes.rb"), "Rails.application.routes.draw do\nend\n")
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  subject do
    Dir.chdir(destination_root) do
      run_generator(options)
    end
  end

  let(:options) { [] }
  let(:model_explorer_routes) { "mount ModelExplorer::Engine, at: \"/model_explorer\"" }

  it "generates the initializer" do
    subject
    expect(file("config/initializers/model_explorer.rb")).to exist
  end

  it "does not generate routes by default" do
    subject
    expect(file("config/routes.rb")).not_to contain(model_explorer_routes)
  end

  context "when routes are specified" do
    let(:options) { ["--routes"] }

    it "generates routes when specified" do
      subject
      expect(file("config/routes.rb")).to contain(model_explorer_routes)
    end
  end
end
