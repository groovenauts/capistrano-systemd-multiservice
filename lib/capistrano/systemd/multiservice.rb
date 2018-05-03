require "capistrano/systemd/multiservice/version"
require "capistrano/systemd/multiservice/system_service"
require "capistrano/systemd/multiservice/user_service"

module Capistrano
  module Systemd
    module MultiService
      SERVICE_TYPES = %w[system user].freeze

      class ServiceTypeError < RuntimeError; end

      def self.new_service(app, service_type: 'system')
        service_type = service_type.to_s
        unless SERVICE_TYPES.include?(service_type)
          raise ServiceTypeError,
                "Service type has to be one of #{SERVICE_TYPES}"
        end

        const_get("#{service_type.capitalize}Service").new(app)
      end
    end
  end
end
