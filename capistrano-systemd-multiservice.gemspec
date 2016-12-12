# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/systemd/multiservice/version'

Gem::Specification.new do |spec|
  spec.name          = "capistrano-systemd-multiservice"
  spec.version       = Capistrano::Systemd::MultiService::VERSION
  spec.authors       = ["YAMADA Tsuyoshi"]
  spec.email         = ["tyamada@minimum2scp.org"]

  spec.summary       = %q{Capistrano Plugin to control services by systemd}
  spec.description   = %q{Capistrano Plugin to control services by systemd}
  spec.homepage      = "https://github.com/groovenauts/capistrano-systemd-multiservice"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", "~> 3.7.0"
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "mocha", "~> 1.2"
end
