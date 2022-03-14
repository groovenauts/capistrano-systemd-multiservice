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

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "capistrano", ">= 3.7.0", "< 3.18.0"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "mocha", "~> 1.2"
end
