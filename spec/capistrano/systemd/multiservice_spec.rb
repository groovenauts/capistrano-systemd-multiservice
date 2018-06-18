require "spec_helper"

describe Capistrano::Systemd::MultiService do
  it "has a version number" do
    expect(Capistrano::Systemd::MultiService::VERSION).not_to be nil
  end
end
