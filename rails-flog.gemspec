# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flog/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-flog'
  spec.version       = Flog::VERSION
  spec.authors       = ['pinzolo']
  spec.email         = ['pinzolo@gmail.com']
  spec.description   = 'This formats parameters and sql in rails log.'
  spec.summary       = 'Rails log formatter for parameters and sql'
  spec.homepage      = 'https://github.com/pinzolo/rails-flog'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'minitest'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sqlite3'

  spec.add_dependency 'anbt-sql-formatter', '>=0.0.7'
  spec.add_dependency 'amazing_print'
  spec.add_dependency 'rails', '>=4.2.0'
end
