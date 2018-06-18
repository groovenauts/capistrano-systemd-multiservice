require "capistrano/systemd/multiservice/version"
require "capistrano/systemd/multiservice/system_service"

module Capistrano
  module Systemd
    module MultiService
      def self.new_service(app)
        SystemService.new(app)
      end
    end
  end
end
