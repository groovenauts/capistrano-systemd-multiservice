$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "rspec"
require "mocha/api"
require "capistrano/systemd/multiservice"
require "capistrano/systemd/multiservice/system_service"
require "capistrano/systemd/multiservice/user_service"

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.mock_framework = :mocha
  config.order = "random"
end

Dir["#{__dir__}/capistrano/systemd/shared/*.rb"].each { |file| require file }
