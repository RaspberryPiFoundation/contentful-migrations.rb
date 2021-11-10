# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'contentful_migrations/version'

Gem::Specification.new do |spec|
  spec.name          = 'contentful-migrations'
  spec.version       = ContentfulMigrations::VERSION
  spec.authors       = ['Kevin English']
  spec.email         = ['me@kenglish.co']

  spec.summary       = 'Contentful Migrations in Ruby'
  spec.description   = 'Migration library system for Contentful API dependent on
                          contentful-management gem and plagarized from activerecord.'
  spec.homepage      = 'https://github.com/monkseal/contentful-migrations.rb'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 2.7.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = Dir['lib/**/*']
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'contentful-management', '~> 3.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'climate_control'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop-rspec'
  spec.add_development_dependency 'simplecov'
end
