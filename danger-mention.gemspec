# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'version'

Gem::Specification.new do |spec|
  spec.name          = 'danger-mention'
  spec.version       = DangerMention::VERSION
  spec.authors       = ['Wojtek Lukaszuk']
  spec.email         = ['wojciech.lukaszuk@icloud.com']
  spec.description   = 'Danger plugin to automatically mention potential reviewers on pull requests.'
  spec.summary       = 'Danger plugin to automatically mention potential reviewers on pull requests.'
  spec.homepage      = 'https://github.com/wojteklu/danger-mention'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.require_paths = ['lib']

  spec.add_dependency 'danger'

  # General ruby development
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake', '~> 10.0'

  # Testing support
  spec.add_development_dependency 'rspec', '~> 3.4'

end
