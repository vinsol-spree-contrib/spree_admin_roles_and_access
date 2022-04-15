# frozen_string_literal: true

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_admin_roles_and_access'
  s.version     = '3-0-stable'
  s.summary     = 'Dynamically defines roles and grants it permissions'
  s.required_ruby_version = '>= 2.7.2'
  s.files = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*']

  s.author    = ["Nishant 'CyRo' Tuteja", 'Akhil Bansal', 'Nimish Mehta']
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://vinsol.com'

  s.require_path = 'lib'
  s.requirements << 'none'

  spree_version = '>= 3.7.0', '< 5.0.0'

  s.add_dependency 'spree_auth_devise'
  s.add_dependency 'spree_core', spree_version

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'brakeman'
  s.add_development_dependency 'bundler-audit'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pg'
  s.add_development_dependency 'rails-controller-testing'
  s.add_development_dependency 'redis'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'rspec-rails', '~> 3.5.0'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-rspec'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'semaphore_test_boosters'
  s.add_development_dependency 'shoulda-matchers', '~> 3.1'
  s.add_development_dependency 'simplecov', '0.21.2'
  s.add_development_dependency 'simplecov-cobertura'
  s.add_development_dependency 'spree', spree_version
  s.add_development_dependency 'spree_auth_devise'
  s.add_development_dependency 'sqlite3'
  s.metadata['rubygems_mfa_required'] = 'true'
end
