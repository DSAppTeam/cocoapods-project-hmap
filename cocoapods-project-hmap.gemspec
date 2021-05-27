# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cocoapods-project-hmap/gem_version.rb'

Gem::Specification.new do |spec|
  spec.name          = 'cocoapods-project-hmap'
  spec.version       = CocoapodsProjectHmap::VERSION
  spec.authors       = ['chenxGen']
  spec.email         = ['chenxGen@outlook.com']
  spec.description   = %q{A cocoapods plugin which using hmap instead of header search paths to improve preprocess time.}
  spec.summary       = %q{A cocoapods plugin which using hmap instead of header search paths to improve preprocess time.}
  spec.homepage      = 'https://github.com/chenxGen/cocoapods-project-hmap'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
