RSpec.shared_context "setup" do
  subject { described_class.new("example") }

  # This allows us to easily use `set`, `fetch`, etc. in the examples.
  let(:env){ Capistrano::Configuration.env }

  # Stub the SSHKit backend so we can set up expectations without the plugin
  # actually executing any commands.
  let(:backend) { stub }
  before { SSHKit::Backend.stubs(:current).returns(backend) }

  # Mimic the deploy flow tasks so that the plugin can register its hooks.
  before do
    Rake::Task.define_task("deploy:check")
    env.set :application, "foo"
    env.set :tmp_dir, "/tmp"
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
      command = systemctl_command + [:status]
      backend.expects(:execute).with(*command)

      subject.systemctl(:status)
    end
  end

  describe "#daemon_reload" do
    it "should run sudo systemctl daemon-reload" do
      command = systemctl_command + [:"daemon-reload"]
      backend.expects(:execute).with(*command)

      subject.daemon_reload
    end
  end
end
