name = 'without config file'
RSpec.shared_examples name do
  context name do
    subject { described_class.new("example4") }

    before do
      env.install_plugin subject, load_immediately: true
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
        command = systemctl_command + [:restart, "example4.service"]
        backend.expects(:execute).with(*command)

        subject.restart
      end
    end

    describe "#reload_or_restart" do
      it "should run systemctl reload-or-restart example4.service" do
        command = systemctl_command + [:"reload-or-restart", "example4.service"]
        backend.expects(:execute).with(*command)

        subject.reload_or_restart
      end
    end

    describe "#enable" do
      it "should run systemctl enable example4.service" do
        command = systemctl_command + [:enable, "example4.service"]
        backend.expects(:execute).with(*command)

        subject.enable
      end
    end
  end
end
