# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elch_scan/version'

Gem::Specification.new do |spec|
  spec.name          = "elch_scan"
  spec.version       = ElchScan::VERSION
  spec.authors       = ["Sven Pachnit"]
  spec.email         = ["sven@bmonkeys.net"]
  spec.summary       = %q{ODO: Write a short summary. Required.}
  spec.description   = %q{ODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "active_support"
  spec.add_runtime_dependency "i18n"
  spec.add_runtime_dependency "pry"
  spec.add_runtime_dependency "xml-simple"
  spec.add_runtime_dependency "streamio-ffmpeg"

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
