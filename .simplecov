# frozen_string_literal: true

require "simplecov-json"
require "model_explorer"

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::JSONFormatter
])

SimpleCov.start do
  add_group "ModelExplorer", ["model_explorer", "spec/features"]
  add_group "Rails", ["/app/", "/config/", "spec/serializers", "spec/requests"]

  add_filter "/spec/rails_helper.rb"
  add_filter "/spec/rails_app/"
end
