# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flog/version'

Gem::Specification.new do |spec|
  spec.name          = 'rails-flog'
  spec.version       = Flog::VERSION
  spec.authors       = ['pinzolo']
  spec.email         = ['pinzolo@gmail.com']

  spec.summary       = 'Rails log formatter for parameters and sql'
  spec.description   = 'This formats parameters and sql in rails log.'
  spec.homepage      = 'https://github.com/pinzolo/rails-flog'
  spec.license       = 'MIT'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

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
