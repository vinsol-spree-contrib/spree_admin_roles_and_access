# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_admin_roles_and_access'
  s.version     = '3.1.0'
  s.summary     = 'Dynamically defines roles and grants it permissions'
  s.required_ruby_version = '>= 2.1.0'
  s.files = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*']

  s.author    = "Nishant 'CyRo' Tuteja"
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://vinsol.com'

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 3.1.0.beta'
  s.add_dependency 'spree_auth_devise', '~> 3.1.0'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.1.0'
  s.add_development_dependency 'shoulda-matchers', '~> 2.8'
  s.add_development_dependency 'rspec-activemodel-mocks'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'factory_girl_rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'poltergeist'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'

end
