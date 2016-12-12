require "erb"
require "stringio"
require "capistrano/plugin"
require "capistrano/systemd/multiservice/version"

module Capistrano
  module Systemd
    class MultiService < ::Capistrano::Plugin
      attr_reader :app

      def initialize(app)
        @app = app
        super()
      end

      def nsp
        @app.to_sym
      end

      def prefix
        "systemd_#{@app}"
      end

      def define_tasks
        eval_rakefile File.expand_path("../../tasks/systemd/multiservice.rake", __FILE__)
      end

      def register_hooks
        after   "deploy:check",          "systemd:#{nsp}:validate"
        after   "systemd:#{nsp}:setup",  "systemd:#{nsp}:daemon-reload"
        after   "systemd:#{nsp}:setup",  "systemd:#{nsp}:enable"
        before  "systemd:#{nsp}:remove", "systemd:#{nsp}:disable"
        after   "systemd:#{nsp}:remove", "systemd:#{nsp}:daemon-reload"
      end

      def set_defaults
        set_if_empty :"#{prefix}_role", ->{ :app }

        set_if_empty :"#{prefix}_units_src", ->{ Dir["config/systemd/#{@app}{,@}.*.erb"].sort }

        set_if_empty :"#{prefix}_units_dir", ->{ "/etc/systemd/system" }

        set_if_empty :"#{prefix}_units_dest", ->{
          fetch(:"#{prefix}_units_src").map{|src|
            "%s/%s_%s" % [ fetch(:"#{prefix}_units_dir"), fetch(:application), File.basename(src, ".erb") ]
          }
        }

        set_if_empty :"#{prefix}_instances", ->{
          if fetch(:"#{prefix}_units_dest").map{|dst| File.basename(dst) }.find{|f| f =~ /@\.service\z/ }
            1.times.to_a
          else
            nil
          end
        }

        set_if_empty :"#{prefix}_service", ->{
          service = fetch(:"#{prefix}_units_dest").map{|dst| File.basename(dst) }.find{|f| f =~ /\.service\z/ && f !~ /@\.service\z/ }
          service || fetch(:"#{prefix}_instance_services")
        }

        set_if_empty :"#{prefix}_instance_services", ->{
          if fetch(:"#{prefix}_instances")
            fetch(:"#{prefix}_instances").map{|i|
              service_template = fetch(:"#{prefix}_units_dest").map{|dst| File.basename(dst) }.find{|f| f =~ /@\.service\z/ }
              service_template && service_template.sub(/@\.service\z/, "@#{i}.service")
            }.flatten
          else
            []
          end
        }
      end

      def setup
        fetch(:"#{prefix}_units_src").zip(fetch(:"#{prefix}_units_dest")).each do |src, dest|
          remote_tmp  = "#{fetch(:tmp_dir)}/#{File.basename(src, ".erb")}"
          backend.upload! StringIO.new(ERB.new(File.read(src), nil, 2).result(binding)), remote_tmp
          backend.sudo :install, '-m 644 -o root -g root -D', remote_tmp, dest
          backend.execute :rm, remote_tmp
        end
      end

      def remove
        backend.sudo :rm, '-f', '--', fetch(:"#{prefix}_units_dest")
      end

      def validate
        fetch(:"#{prefix}_units_dest").each do |dest|
          unless backend.test("[ -f #{dest} ]")
            backend.error "#{dest} not found"
            exit 1
          end
        end
      end

      def daemon_reload
        systemctl :"daemon-reload"
      end

      %i[start stop reload restart reload-or-restart enable disable].each do |act|
        define_method act.to_s.tr('-','_') do
          systemctl act, fetch(:"#{prefix}_service")
        end
      end

      def systemctl(*args)
        args.unshift :sudo, :systemctl
        backend.execute(*args)
      end
    end
  end
end
