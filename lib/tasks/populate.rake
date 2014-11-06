namespace :spree_roles do
  namespace :permissions do
    desc "Create admin username and password"
    task :populate => :environment do
      admin = Spree::Role.where(name: 'admin').first_or_create!
      user = Spree::Role.where(name: 'user').first_or_create!
      user.is_default = true
      user.save!

      permission1 = Spree::Permission.create!(title: 'can-manage-all', priority: 0)
      permission2 = Spree::Permission.create!(title: 'default-permissions', priority: 1)

      user.permissions = [permission2]
      admin.permissions = [permission1]
    end
    task :populate_other_roles => :environment do
      manager = Spree::Role.where(name: 'manager').first_or_create!
      customer_service = Spree::Role.where(name: 'customer service').first_or_create!
      warehouse = Spree::Role.where(name: 'warehouse').first_or_create!

      permission2 = Spree::Permission.create!(title: 'default-permissions', priority: 1)
      permission3 = Spree::Permission.create!(title: 'can-manage-spree/products', priority: 2) 
      permission4 = Spree::Permission.create!(title: 'can-manage-spree/orders', priority: 2) 
      permission5 = Spree::Permission.create!(title: 'can-manage-spree/users', priority: 2)
      permission6 = Spree::Permission.create(title: 'can-manage-spree/stock_locations', priority: 2)
      
      permission7 = Spree::Permission.create(title: 'can-read-spree/products', priority: 3)
      permission8 = Spree::Permission.create(title: 'can-index-spree/products', priority: 3)
      permission9 = Spree::Permission.create(title: 'can-update-spree/products', priority: 3)
      permission10 = Spree::Permission.create(title: 'can-create-spree/products', priority: 3)

      permission11 = Spree::Permission.create(title: 'can-read-spree/users', priority: 3)
      permission12 = Spree::Permission.create(title: 'can-index-spree/users', priority: 3)
      permission13 = Spree::Permission.create(title: 'can-update-spree/users', priority: 3)
      permission14 = Spree::Permission.create(title: 'can-create-spree/users', priority: 3)

      permission15 = Spree::Permission.create(title: 'can-read-spree/orders', priority: 3)
      permission16 = Spree::Permission.create(title: 'can-index-spree/orders', priority: 3)
      permission17 = Spree::Permission.create(title: 'can-update-spree/orders', priority: 3)
      permission18 = Spree::Permission.create(title: 'can-create-spree/orders', priority: 3)

      permission19 = Spree::Permission.create(title: 'can-read-spree/stock_locations', priority: 3)
      permission20 = Spree::Permission.create(title: 'can-index-spree/stock_locations', priority: 3)
      permission21 = Spree::Permission.create(title: 'can-update-spree/stock_locations', priority: 3)
      permission22 = Spree::Permission.create(title: 'can-create-spree/stock_locations', priority: 3)

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