$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rspec"
require "mocha/api"
require "capistrano/systemd/multiservice"

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_framework = :mocha
  config.order = "random"
end
