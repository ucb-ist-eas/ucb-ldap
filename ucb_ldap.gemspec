lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ucb_ldap/version'

Gem::Specification.new do |spec|
  spec.name          = "ucb_ldap"
  spec.version       = UcbLdap::VERSION
  spec.authors       = ["Steven Hansen, Steve Downey"]
  spec.email         = %w{sahglie@gmail.com}
  spec.description   = %q{Convenience classes for interacing with UCB's LDAP directory}
  spec.summary       = %q{Convenience classes for interacing with UCB's LDAP directory}
  spec.homepage      = "https://github.com/sahglie/ucb-ldap"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"

  spec.add_runtime_dependency "net-ldap", "0.2.2"
end
