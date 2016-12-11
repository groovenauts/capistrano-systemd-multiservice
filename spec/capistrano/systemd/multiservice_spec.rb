require "spec_helper"

describe Capistrano::Systemd::MultiService do
  it "has a version number" do
    expect(Capistrano::Systemd::MultiService::VERSION).not_to be nil
  end

  subject { Capistrano::Systemd::MultiService.new("example") }

  # This allows us to easily use `set`, `fetch`, etc. in the examples.
  let(:env){ Capistrano::Configuration.env }

  # Stub the SSHKit backend so we can set up expectations without the plugin
  # actually executing any commands.
  let(:backend) { stub }
  before { SSHKit::Backend.stubs(:current).returns(backend) }

  # Mimic the deploy flow tasks so that the plugin can register its hooks.
  before do
    Rake::Task.define_task("deploy:check")
  end

  # Clean up any tasks or variables that the plugin defined.
  after do
    Rake::Task.clear
    Capistrano::Configuration.reset!
  end

  describe "#nsp" do
    it "should be :example" do
      expect(subject.nsp).to eq :example
    end
  end

  describe "#prefix" do
    it "should be systemd_example" do
      expect(subject.prefix).to eq "systemd_example"
    end
  end

  describe "#systemctl" do
    it "should run sudo systemctl with arg" do
      backend.expects(:execute).with(:sudo, :systemctl, :status)

      subject.systemctl(:status)
    end
  end

  describe "#daemon_reload" do
    it "should run sudo systemctl daemon-reload" do
      backend.expects(:execute).with(:sudo, :systemctl, :"daemon-reload")

      subject.daemon_reload
    end
  end


  describe "with config/systemd/example1.service.erb" do
    subject { Capistrano::Systemd::MultiService.new("example1") }

    before do
      env.install_plugin subject, load_immediately: true
      env.set :application, "foo"
      env.set :tmp_dir, "/tmp"
      Dir.expects(:[]).with("config/systemd/example1{,@}.*.erb").returns(["config/systemd/example1.service.erb"]).at_most_once
    end

    describe "variables" do
      it "systemd_example1_units_src" do
        expect(env.fetch(:systemd_example1_units_src)).to eq ["config/systemd/example1.service.erb"]
      end

      it "systemd_example1_units_dest" do
        expect(env.fetch(:systemd_example1_units_dest)).to eq ["/etc/systemd/system/foo_example1.service"]
      end

      it "systemd_example1_instances" do
        expect(env.fetch(:systemd_example1_instances)).to eq nil
      end

      it "systemd_example1_service" do
        expect(env.fetch(:systemd_example1_service)).to eq "foo_example1.service"
      end

      it "systemd_example1_instance_services" do
        expect(env.fetch(:systemd_example1_instance_services)).to eq []
      end
    end

    describe "#setup" do
      it "should upload and install unit file" do
        buf = stub
        File.expects(:read).with("config/systemd/example1.service.erb").returns("dummy")
        StringIO.expects(:new).with("dummy").returns(buf)

        backend.expects(:upload!).with(buf, "/tmp/example1.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example1.service", "/etc/systemd/system/foo_example1.service")
        backend.expects(:execute).with(:rm, "/tmp/example1.service")

        subject.setup
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:sudo).with(:rm, '-f', '--', ["/etc/systemd/system/foo_example1.service"])

        subject.remove
      end
    end

    describe "#validate" do
      it "does not exit if unit file exist" do
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example1.service ]").returns(true)

        subject.validate
      end

      it "exit if unit file does not exist" do
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example1.service ]").returns(false)
        backend.expects(:error).with("/etc/systemd/system/foo_example1.service not found")

        expect{ subject.validate }.to raise_error SystemExit
      end
    end

    describe "#restart" do
      it "should run systemctl restart foo_example1.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :restart, "foo_example1.service")

        subject.restart
      end
    end

    describe "#reload_or_restart" do
      it "should run systemctl reload-or-restart foo_example1.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :"reload-or-restart", "foo_example1.service")

        subject.reload_or_restart
      end
    end

    describe "#enable" do
      it "should run systemctl enable foo_example1.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :enable, "foo_example1.service")

        subject.enable
      end
    end
  end


  describe "with config/systemd/example2.service.erb, example2@.service.erb" do
    subject { Capistrano::Systemd::MultiService.new("example2") }

    before do
      env.install_plugin subject, load_immediately: true
      env.set :application, "foo"
      env.set :tmp_dir, "/tmp"
      Dir.expects(:[]).with("config/systemd/example2{,@}.*.erb").returns(["config/systemd/example2.service.erb", "config/systemd/example2@.service.erb"]).at_most_once
    end

    describe "variables" do
      it "systemd_example2_units_src" do
        expect(env.fetch(:systemd_example2_units_src)).to eq ["config/systemd/example2.service.erb", "config/systemd/example2@.service.erb"]
      end

      it "systemd_example2_units_dest" do
        expect(env.fetch(:systemd_example2_units_dest)).to eq ["/etc/systemd/system/foo_example2.service", "/etc/systemd/system/foo_example2@.service"]
      end

      it "systemd_example2_instances" do
        expect(env.fetch(:systemd_example2_instances)).to eq [0]
      end

      it "systemd_example2_service" do
        expect(env.fetch(:systemd_example2_service)).to eq "foo_example2.service"
      end

      it "systemd_example2_instance_services" do
        expect(env.fetch(:systemd_example2_instance_services)).to eq ["foo_example2@0.service"]
      end
    end

    describe "#setup" do
      it "should upload and install unit file" do
        buf1 = stub
        File.expects(:read).with("config/systemd/example2.service.erb").returns("dummy1")
        StringIO.expects(:new).with("dummy1").returns(buf1)

        backend.expects(:upload!).with(buf1, "/tmp/example2.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example2.service", "/etc/systemd/system/foo_example2.service")
        backend.expects(:execute).with(:rm, "/tmp/example2.service")

        buf2 = stub
        File.expects(:read).with("config/systemd/example2@.service.erb").returns("dummy2")
        StringIO.expects(:new).with("dummy2").returns(buf2)

        backend.expects(:upload!).with(buf2, "/tmp/example2@.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example2@.service", "/etc/systemd/system/foo_example2@.service")
        backend.expects(:execute).with(:rm, "/tmp/example2@.service")

        subject.setup
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:sudo).with(:rm, '-f', '--', ["/etc/systemd/system/foo_example2.service", "/etc/systemd/system/foo_example2@.service"])

        subject.remove
      end
    end

    describe "#validate" do
      it "does not exit if unit file exist" do
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example2.service ]").returns(true)
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example2@.service ]").returns(true)

        subject.validate
      end

      it "exit if unit file does not exist" do
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example2.service ]").returns(true)
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example2@.service ]").returns(false)
        backend.expects(:error).with("/etc/systemd/system/foo_example2@.service not found")

        expect{ subject.validate }.to raise_error SystemExit
      end
    end

    describe "#restart" do
      it "should run systemctl restart foo_example2.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :restart, "foo_example2.service")

        subject.restart
      end
    end

    describe "#reload_or_restart" do
      it "should run systemctl reload-or-restart foo_example2.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :"reload-or-restart", "foo_example2.service")

        subject.reload_or_restart
      end
    end

    describe "#enable" do
      it "should run systemctl enable foo_example2.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :enable, "foo_example2.service")

        subject.enable
      end
    end
  end


  describe "with config/systemd/example3@.service.erb" do
    subject { Capistrano::Systemd::MultiService.new("example3") }

    before do
      env.install_plugin subject, load_immediately: true
      env.set :application, "foo"
      env.set :tmp_dir, "/tmp"
      env.set :systemd_example3_instances, 3.times.to_a
      Dir.expects(:[]).with("config/systemd/example3{,@}.*.erb").returns(["config/systemd/example3@.service.erb"]).at_most_once
    end

    describe "variables" do
      it "systemd_example3_units_src" do
        expect(env.fetch(:systemd_example3_units_src)).to eq ["config/systemd/example3@.service.erb"]
      end

      it "systemd_example3_units_dest" do
        expect(env.fetch(:systemd_example3_units_dest)).to eq ["/etc/systemd/system/foo_example3@.service"]
      end

      it "systemd_example3_service" do
        expect(env.fetch(:systemd_example3_service)).to eq ["foo_example3@0.service", "foo_example3@1.service", "foo_example3@2.service"]
      end

      it "systemd_example3_instance_services" do
        expect(env.fetch(:systemd_example3_instance_services)).to eq ["foo_example3@0.service", "foo_example3@1.service", "foo_example3@2.service"]
      end
    end

    describe "#setup" do
      it "should upload and install unit file" do
        buf2 = stub
        File.expects(:read).with("config/systemd/example3@.service.erb").returns("dummy2")
        StringIO.expects(:new).with("dummy2").returns(buf2)

        backend.expects(:upload!).with(buf2, "/tmp/example3@.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example3@.service", "/etc/systemd/system/foo_example3@.service")
        backend.expects(:execute).with(:rm, "/tmp/example3@.service")

        subject.setup
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:sudo).with(:rm, '-f', '--', ["/etc/systemd/system/foo_example3@.service"])

        subject.remove
      end
    end

    describe "#validate" do
      it "does not exit if unit file exist" do
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example3@.service ]").returns(true)

        subject.validate
      end

      it "exit if unit file does not exist" do
        backend.expects(:test).with("[ -f /etc/systemd/system/foo_example3@.service ]").returns(false)
        backend.expects(:error).with("/etc/systemd/system/foo_example3@.service not found")

        expect{ subject.validate }.to raise_error SystemExit
      end
    end

    describe "#restart" do
      it "should run systemctl restart foo_example3.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :restart, ["foo_example3@0.service", "foo_example3@1.service", "foo_example3@2.service"])

        subject.restart
      end
    end

    describe "#reload_or_restart" do
      it "should run systemctl reload-or-restart foo_example3.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :"reload-or-restart", ["foo_example3@0.service", "foo_example3@1.service", "foo_example3@2.service"])

        subject.reload_or_restart
      end
    end

    describe "#enable" do
      it "should run systemctl enable foo_example3.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :enable, ["foo_example3@0.service", "foo_example3@1.service", "foo_example3@2.service"])

        subject.enable
      end
    end
  end


  describe "without config file" do
    subject { Capistrano::Systemd::MultiService.new("example4") }

    before do
      env.install_plugin subject, load_immediately: true
      env.set :application, "foo"
      env.set :tmp_dir, "/tmp"
      env.set :systemd_example4_service, "example4.service"
      Dir.expects(:[]).with("config/systemd/example4{,@}.*.erb").returns([]).at_most_once
    end

    describe "variables" do
      it "systemd_example4_units_src" do
        expect(env.fetch :systemd_example4_units_src).to eq []
      end

      it "systemd_example4_units_dest" do
        expect(env.fetch(:systemd_example4_units_dest)).to eq []
      end

      it "systemd_example4_instances" do
        expect(env.fetch(:systemd_example4_instances)).to eq nil
      end

      it "systemd_example4_service" do
        expect(env.fetch(:systemd_example4_service)).to eq "example4.service"
      end

      it "systemd_example4_instance_services" do
        expect(env.fetch(:systemd_example4_instance_services)).to eq []
      end
    end

    describe "#validate" do
      it do
        expect{ subject.validate }.not_to raise_error
      end
    end

    describe "#restart" do
      it "should run systemctl restart example4.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :restart, "example4.service")

        subject.restart
      end
    end

    describe "#reload_or_restart" do
      it "should run systemctl reload-or-restart example4.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :"reload-or-restart", "example4.service")

        subject.reload_or_restart
      end
    end

    describe "#enable" do
      it "should run systemctl enable example4.service" do
        backend.expects(:execute).with(:sudo, :systemctl, :enable, "example4.service")

        subject.enable
      end
    end
  end
end
