# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'heroku-schemas/version'

Gem::Specification.new do |s|
  s.name        = 'heroku-schemas'
  s.version     = HerokuSchemas::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Tom Benner']
  s.email       = ['tombenner@gmail.com']
  s.homepage    = 'https://github.com/tombenner/heroku-schemas'
  s.summary = s.description = %q{Run many apps on a single database.}

  s.rubyforge_project = 'heroku-schemas'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ['lib']

  s.add_dependency 'heroku', '~> 3.0.0'
  s.add_dependency 'heroku-api'
  s.add_dependency 'pg'
  s.add_dependency 'activerecord', '3.2.0'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'cucumber'
  s.add_development_dependency 'aruba'
end
