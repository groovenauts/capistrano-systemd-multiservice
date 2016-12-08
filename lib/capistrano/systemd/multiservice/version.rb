begin
  require "capistrano/plugin"
rescue LoadError
  module Capistrano
    class Plugin; end
  end
end

module Capistrano
  module Systemd
    class MultiService < ::Capistrano::Plugin
      VERSION = "0.1.0.beta1"
    end
  end
end
