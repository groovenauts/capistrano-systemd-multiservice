require "spec_helper"

describe Capistrano::Systemd::MultiService::UserService do
  let(:systemd_dir) { "/home/user/.config/systemd/user" }
  let(:systemctl_command) { [:systemctl, "--user"] }

  include_context "setup"

  before { env.set :user, "user" }

  context do
    include_context "with config/systemd/example1.service.erb"

    describe "#setup" do
      it "should upload and install unit file" do
        buf = stub
        File.expects(:read).with("config/systemd/example1.service.erb").returns("dummy")
        StringIO.expects(:new).with("dummy").returns(buf)

        backend.expects(:upload!).with(buf, "/home/user/.config/systemd/user/foo_example1.service")

        subject.setup
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:execute).with(:rm, '-f', '--', ["/home/user/.config/systemd/user/foo_example1.service"])

        subject.remove
      end
    end
  end

  context do
    include_context "with config/systemd/example2.service.erb, example2@.service.erb"

    describe "#setup" do
      it "should upload and install unit file" do
        buf1 = stub
        File.expects(:read).with("config/systemd/example2.service.erb").returns("dummy1")
        StringIO.expects(:new).with("dummy1").returns(buf1)

        backend.expects(:upload!).with(buf1, "/home/user/.config/systemd/user/foo_example2.service")

        buf2 = stub
        File.expects(:read).with("config/systemd/example2@.service.erb").returns("dummy2")
        StringIO.expects(:new).with("dummy2").returns(buf2)

        backend.expects(:upload!).with(buf2, "/home/user/.config/systemd/user/foo_example2@.service")

        subject.setup
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:execute).with(:rm, '-f', '--', ["/home/user/.config/systemd/user/foo_example2.service", "/home/user/.config/systemd/user/foo_example2@.service"])

        subject.remove
      end
    end
  end

  context do
    include_context "with config/systemd/example3@.service.erb"

    describe "#setup" do
      it "should upload and install unit file" do
        buf2 = stub
        File.expects(:read).with("config/systemd/example3@.service.erb").returns("dummy2")
        StringIO.expects(:new).with("dummy2").returns(buf2)

        backend.expects(:upload!).with(buf2, "#{systemd_dir}/foo_example3@.service")

        subject.setup
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:execute).with(:rm, '-f', '--', ["#{systemd_dir}/foo_example3@.service"])

        subject.remove
      end
    end
  end

  include_examples "without config file" do
    let(:systemctl_command) { [:systemctl, "--user"] }
  end
end
