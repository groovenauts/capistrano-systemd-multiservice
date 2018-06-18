require "spec_helper"

describe Capistrano::Systemd::MultiService do
  it "has a version number" do
    expect(Capistrano::Systemd::MultiService::VERSION).not_to be nil
  end

  describe "Capistrano::Systemd::MultiService.new_service" do
    context "with 'example' argument" do
      subject {
        Capistrano::Systemd::MultiService.new_service('example')
      }
      it do
        expect(subject).to be_an_instance_of(Capistrano::Systemd::MultiService::SystemService).and have_attributes(app: "example")
      end
    end
  end
end
