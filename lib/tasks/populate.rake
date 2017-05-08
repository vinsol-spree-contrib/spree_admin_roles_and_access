namespace :spree_roles do
  namespace :permissions do

    def do_permission_setup(permission, permission_set_name, role, priority)
      permission = Spree::Permission.where(title: permission, priority: priority).first_or_create!
      permission_set = Spree::PermissionSet.where(name: permission_set_name).first_or_initialize
      create_role_with_permission_sets([permission_set], role)
    end

    def create_role_with_permission_sets(permission_sets, role)
      role = Spree::Role.where(name: role).first_or_initialize
      permission_sets.each do |permission_set|
        unless role.permission_sets.include? permission_set
          role.permission_sets << permission_set
        end
      end
      role.save!
      role
    end

    desc "Create admin username and password"

    task populate: :environment do
      do_permission_setup('can-manage-all', 'admin', 'admin', 0)
      default_role = do_permission_setup('default-permissions', 'default', 'default', 1)
      default_role.is_default = true
      default_role.save!
    end

    task populate_other_roles: :environment do
      default_permission_set = Spree::PermissionSet.find_by(name: 'default')

      manager = Spree::Role.where(name: 'manager').first_or_create!
      customer_service = Spree::Role.where(name: 'customer service').first_or_create!
      warehouse = Spree::Role.where(name: 'warehouse').first_or_create!

      permission2 = Spree::Permission.where(title: 'default-permissions', priority: 1).first_or_create!
      permission3 = Spree::Permission.where(title: 'can-manage-spree/products', priority: 2).first_or_create!
      permission4 = Spree::Permission.where(title: 'can-manage-spree/orders', priority: 2).first_or_create!
      permission5 = Spree::Permission.where(title: 'can-manage-spree/users', priority: 2).first_or_create!
      permission6 = Spree::Permission.where(title: 'can-manage-spree/stock_locations', priority: 2).first_or_create!

      permission7 = Spree::Permission.where(title: 'can-read-spree/products', priority: 3).first_or_create!
      permission8 = Spree::Permission.where(title: 'can-index-spree/products', priority: 3).first_or_create!
      permission9 = Spree::Permission.where(title: 'can-update-spree/products', priority: 3).first_or_create!
      permission10 = Spree::Permission.where(title: 'can-create-spree/products', priority: 3).first_or_create!

      permission11 = Spree::Permission.where(title: 'can-read-spree/users', priority: 3).first_or_create!
      permission12 = Spree::Permission.where(title: 'can-index-spree/users', priority: 3).first_or_create!
      permission13 = Spree::Permission.where(title: 'can-update-spree/users', priority: 3).first_or_create!
      permission14 = Spree::Permission.where(title: 'can-create-spree/users', priority: 3).first_or_create!

      permission15 = Spree::Permission.where(title: 'can-read-spree/orders', priority: 3).first_or_create!
      permission16 = Spree::Permission.where(title: 'can-index-spree/orders', priority: 3).first_or_create!
      permission17 = Spree::Permission.where(title: 'can-update-spree/orders', priority: 3).first_or_create!
      permission18 = Spree::Permission.where(title: 'can-create-spree/orders', priority: 3).first_or_create!

      permission19 = Spree::Permission.where(title: 'can-read-spree/stock_locations', priority: 3).first_or_create!
      permission20 = Spree::Permission.where(title: 'can-index-spree/stock_locations', priority: 3).first_or_create!
      permission21 = Spree::Permission.where(title: 'can-update-spree/stock_locations', priority: 3).first_or_create!
      permission22 = Spree::Permission.where(title: 'can-create-spree/stock_locations', priority: 3).first_or_create!

      permission23 = Spree::Permission.where(title: 'can-manage-spree/taxons', priority: 2).first_or_create!
      permission24 = Spree::Permission.where(title: 'can-manage-spree/option_types', priority: 2).first_or_create!
      permission25 = Spree::Permission.where(title: 'can-manage-spree/taxonomies', priority: 2).first_or_create!
      permission26 = Spree::Permission.where(title: 'can-manage-spree/images', priority: 2).first_or_create!
      permission27 = Spree::Permission.where(title: 'can-manage-spree/product_properties', priority: 2).first_or_create!
      permission28 = Spree::Permission.where(title: 'can-manage-spree/stocks', priority: 2).first_or_create!

      manager.permissions = [ permission2,
                              permission3,
                              permission4,
                              permission24,
                              permission25,
                              permission26,
                              permission27,
                              permission28,
                              permission6
                            ]
      customer_service.permissions =  [ permission2,
                                        permission15,
                                        permission16,
                                        permission17
                                      ]
      warehouse.permissions = [ permission2,
                                permission4,
                                permission6,
                                permission15,
                                permission16,
                                permission17,
                                permission28
                              ]
    end
  end
end
