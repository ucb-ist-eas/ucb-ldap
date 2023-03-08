lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ucb_ldap/version'

Gem::Specification.new do |spec|
  spec.name          = "ucb_ldap"
  spec.version       = UcbLdap::VERSION
  spec.authors       = ["Steven Hansen, Steve Downey, Darin Wilson"]
  spec.email         = %w{adminit@berkeley.edu}
  spec.description   = %q{Convenience classes for interacing with UCB's LDAP directory}
  spec.summary       = %q{Convenience classes for interacing with UCB's LDAP directory}
  spec.homepage      = "https://github.com/ucb-ist-eas/ucb-ldap"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/}) || f.match(/ucb_rails_cli.*\.gem/)
  end

  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "net-ldap", "0.17.1"
end
