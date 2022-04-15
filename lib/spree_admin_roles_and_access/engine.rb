module SpreeAdminRolesAndAccess
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    isolate_namespace SpreeAdminRolesAndAccess
    engine_name 'spree_admin_roles_and_access'

    config.autoload_paths += %W(#{config.root}/lib #{config.root}/app)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
