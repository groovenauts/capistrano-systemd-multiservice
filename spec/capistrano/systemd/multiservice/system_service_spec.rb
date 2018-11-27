require "spec_helper"

describe Capistrano::Systemd::MultiService::SystemService do
  let(:systemd_dir) { "/etc/systemd/system" }
  let(:systemctl_command) { %i[sudo systemctl] }

  include_context "setup"

  context do
    include_context "with config/systemd/example1.service.erb"

    describe "#setup" do
      it "should upload and install unit file" do
        buf = stub
        File.expects(:read).with("config/systemd/example1.service.erb").returns("dummy")
        StringIO.expects(:new).with("dummy").returns(buf)

        backend.expects(:upload!).with(buf, "/tmp/example1.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example1.service", "/etc/systemd/system/foo_example1.service")
        backend.expects(:execute).with(:rm, "/tmp/example1.service")

        subject.setup(server)
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:sudo).with(:rm, '-f', '--', ["/etc/systemd/system/foo_example1.service"])

        subject.remove(server)
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

        backend.expects(:upload!).with(buf1, "/tmp/example2.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example2.service", "/etc/systemd/system/foo_example2.service")
        backend.expects(:execute).with(:rm, "/tmp/example2.service")

        buf2 = stub
        File.expects(:read).with("config/systemd/example2@.service.erb").returns("dummy2")
        StringIO.expects(:new).with("dummy2").returns(buf2)

        backend.expects(:upload!).with(buf2, "/tmp/example2@.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example2@.service", "/etc/systemd/system/foo_example2@.service")
        backend.expects(:execute).with(:rm, "/tmp/example2@.service")

        subject.setup(server)
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:sudo).with(:rm, '-f', '--', ["/etc/systemd/system/foo_example2.service", "/etc/systemd/system/foo_example2@.service"])

        subject.remove(server)
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

        backend.expects(:upload!).with(buf2, "/tmp/example3@.service")
        backend.expects(:sudo).with(:install, "-m 644 -o root -g root -D", "/tmp/example3@.service", "/etc/systemd/system/foo_example3@.service")
        backend.expects(:execute).with(:rm, "/tmp/example3@.service")

        subject.setup(server)
      end
    end

    describe "#remove" do
      it "should uninstall unit file" do
        backend.expects(:sudo).with(:rm, '-f', '--', ["/etc/systemd/system/foo_example3@.service"])

        subject.remove(server)
      end
    end
  end

  include_examples "without config file" do
    let(:systemctl_command) { %i[sudo systemctl] }
  end
end
