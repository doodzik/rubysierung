# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubysierung/version'

Gem::Specification.new do |spec|
  spec.name          = "rubysierung"
  spec.version       = Rubysierung::VERSION
  spec.authors       = ["doodzik"]
  spec.email         = ["4004blog@gmail.com"]
  spec.summary       = %q{Rubysierung is the type system Ruby deserves}
  spec.homepage      = "https://github.com/doodzik/rubysierung"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "CallBaecker", "~> 0.0.3"
  spec.add_development_dependency "minitest"
end
