# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_admin_roles_and_access'
  s.version     = '1.2.0'
  s.summary     = 'Dynamically defines roles and grants it permissions'
  s.required_ruby_version = '>= 1.9.3'
  s.files = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*']

  s.author    = "Nishant 'CyRo' Tuteja"
  s.email     = 'info@vinsol.com'
  s.homepage  = 'http://vinsol.com'
  
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.2'
end
