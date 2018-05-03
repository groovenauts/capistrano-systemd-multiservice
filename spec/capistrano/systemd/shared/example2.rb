RSpec.shared_context "with config/systemd/example2.service.erb, example2@.service.erb" do
  subject { described_class.new("example2") }

  before do
    env.install_plugin subject, load_immediately: true
    Dir.expects(:[]).with("config/systemd/example2{,@}.*.erb").returns(["config/systemd/example2.service.erb", "config/systemd/example2@.service.erb"]).at_most_once
  end

  describe "variables" do
    it "systemd_example2_units_src" do
      expect(env.fetch(:systemd_example2_units_src)).to eq ["config/systemd/example2.service.erb", "config/systemd/example2@.service.erb"]
    end

    it "systemd_example2_units_dest" do
      expect(env.fetch(:systemd_example2_units_dest)).to eq ["#{systemd_dir}/foo_example2.service", "#{systemd_dir}/foo_example2@.service"]
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

  describe "#validate" do
    it "does not exit if unit file exist" do
      backend.expects(:test).with("[ -f #{systemd_dir}/foo_example2.service ]").returns(true)
      backend.expects(:test).with("[ -f #{systemd_dir}/foo_example2@.service ]").returns(true)

      subject.validate
    end

    it "exit if unit file does not exist" do
      backend.expects(:test).with("[ -f #{systemd_dir}/foo_example2.service ]").returns(true)
      backend.expects(:test).with("[ -f #{systemd_dir}/foo_example2@.service ]").returns(false)
      backend.expects(:error).with("#{systemd_dir}/foo_example2@.service not found")

      expect{ subject.validate }.to raise_error SystemExit
    end
  end

  describe "#restart" do
    it "should run systemctl restart foo_example2.service" do
      command = systemctl_command + [:restart, "foo_example2.service"]
      backend.expects(:execute).with(*command)

      subject.restart
    end
  end

  describe "#reload_or_restart" do
    it "should run systemctl reload-or-restart foo_example2.service" do
      command = systemctl_command + [:"reload-or-restart", "foo_example2.service"]
      backend.expects(:execute).with(*command)

      subject.reload_or_restart
    end
  end

  describe "#enable" do
    it "should run systemctl enable foo_example2.service" do
      command = systemctl_command + [:enable, "foo_example2.service"]
      backend.expects(:execute).with(*command)

      subject.enable
    end
  end
end
