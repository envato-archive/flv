# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "flv/version"

Gem::Specification.new do |spec|
  spec.name          = "flv"
  spec.version       = FLV::VERSION
  spec.authors       = ["Charlie Somerville"]
  spec.email         = ["charlie@charliesomerville.com"]
  spec.description   = %q{A library for handling FLV files}
  spec.summary       = %q{Ruby library for parsing and handling FLV files}
  spec.homepage      = "https://github.com/envato/flv"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
