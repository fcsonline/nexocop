# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nexocop/version'

Gem::Specification.new do |s|
  s.name        = 'nexocop'
  s.version     = Nexocop.version
  s.date        = Nexocop.date
  s.summary     = 'Easy rubocop wrapping for git diffs'
  s.description = 'Nexocop makes it trivial to add rubocop linting to your ' \
    'project that will only check linting against lines that have changed in ' \
    'git.  Rubocop normally is not git aware.  This gem makes it git aware.'
  s.authors     = ['Ben Porter']
  s.email       = 'bporter@simplenexus.com'
  s.files       = ['lib/nexocop.rb'] + Dir['lib/nexocop/**/*']
  s.homepage    = 'https://github.com/SimpleNexus/nexocop'
  s.license     = 'MIT'

  s.required_ruby_version = '>= 2.3.0'

  s.executables << 'nexocop'

  s.add_runtime_dependency 'rainbow', '~> 3.0'
  s.add_runtime_dependency 'rubocop', '~> 0.59'

  s.add_development_dependency 'byebug', '~> 10.0'
  s.add_development_dependency 'rake', '~> 12.3'
  s.add_development_dependency 'rspec', '~> 3.8'
end
