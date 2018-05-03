require "spec_helper"

describe Capistrano::Systemd::MultiService do
  it "has a version number" do
    expect(described_class::VERSION).not_to be nil
  end

  describe ".new_service" do
    context "with 'example' argument" do
      subject { described_class.new_service('example') }

      it do
        expect(subject).to be_an_instance_of(described_class::SystemService).and have_attributes(app: "example")
      end
    end

    context 'when asking for user service type' do
      subject { described_class.new_service('example', service_type: 'user') }

      it { is_expected.to be_a(described_class::UserService) }
    end

    context 'when asking for non-existent service type' do
      subject { described_class.new_service('example', service_type: 'xyz') }

      it 'exits with exception' do
        expect { subject }.to raise_error(described_class::ServiceTypeError)
      end
    end
  end
end
