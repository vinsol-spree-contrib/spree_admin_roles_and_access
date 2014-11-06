namespace :spree_roles do
  namespace :permissions do
    desc "Create admin username and password"
    task :populate => :environment do
      admin = Spree::Role.where(name: 'admin').first_or_create!
      user = Spree::Role.where(name: 'user').first_or_create!
      user.is_default = true
      user.save!

      permission1 = Spree::Permission.where(title: 'can-manage-all', priority: 0).first_or_create!
      permission2 = Spree::Permission.where(title: 'default-permissions', priority: 1).first_or_create!

      user.permissions = [permission2]
      admin.permissions = [permission1]
    end
    task :populate_other_roles => :environment do
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

      manager.permissions = [ permission2, 
                              permission3, 
                              permission4, 
                              permission6
                            ]
      customer_service.permissions =  [ permission2, 
                                        permission15, 
                                        permission16, 
                                        permission17
                                      ]
      warehouse.permissions = [ permission2, 
                                permission6,
                                permission15, 
                                permission16, 
                                permission17
                              ]
    end
  end
end