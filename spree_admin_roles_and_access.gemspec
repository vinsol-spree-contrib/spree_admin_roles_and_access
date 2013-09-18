# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_admin_roles_and_access'
  s.version     = '2.0.3'
  s.summary     = 'Dynamically defines roles and grants it permissions'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = "Nishant 'CyRo' Tuteja"
  s.email     = 'nishant.tuteja@vinsol.com'

  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.0.3'

  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'mysql2'
end
