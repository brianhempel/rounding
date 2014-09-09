# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rounding/version'

Gem::Specification.new do |spec|
  spec.name          = "rounding"
  spec.version       = Rounding::VERSION
  spec.authors       = ["Brian Hempel"]
  spec.email         = ["plasticchicken@gmail.com"]
  spec.summary       = %q{Floor/nearest/ceiling rounding by arbitrary steps for Integers, Floats, Times, TimeWithZones, and DateTimes.}
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/brianhempel/rounding"
  spec.license       = "Public Domain"

  spec.files         = `git ls-files -z`.split("\x0")
  # spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "activesupport"
end
