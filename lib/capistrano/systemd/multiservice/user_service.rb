require_relative './system_service'

module Capistrano
  module Systemd
    module MultiService
      class UserService < SystemService
        def systemctl(*args)
          args.unshift :systemctl, '--user'
          backend.execute(*args)
        end

        def remove
          backend.execute :rm, '-f', '--', fetch(:"#{prefix}_units_dest")
        end

        def default_units_dir
          "/home/#{fetch(:user)}/.config/systemd/user"
        end

        protected

        def setup_service(buf, src, dest)
          backend.upload! buf, dest
        end
      end
    end
  end
end
