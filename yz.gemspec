# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.any? { |lp| File.expand_path(lp) == File.expand_path(lib) }
require 'yz/version'

Gem::Specification.new do |spec|
  spec.name          = 'yz'
  spec.version       = Yz::VERSION
  spec.authors       = ['Ethan']
  spec.email         = ['ethan@unth']
  spec.summary       = 'yz'
  spec.description   = 'yz'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0") - ['.gitignore']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'ffi-rzmq', '~> 2.0'
end
