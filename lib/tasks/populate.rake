namespace :spree_roles do
  namespace :permissions do

    def description_from_title(title)
      permission = title.split('/')
      description = ["Permitted user"]
      description << permission.first.gsub('-', '_').gsub('index', 'list').gsub('_spree', '').titleize
      description << permission.second.titleize if permission[1].present?
      description.join(" ")
    end

    def make_permission(title, priority)
      permission = Spree::Permission.where(title: title).first_or_create!
      permission.priority =  priority
      permission.description = description_from_title(title)
      permission.save!
      permission
    end

    def make_permission_set(permissions, permission_set_name, description, display_permission: false)
      permission_set = Spree::PermissionSet.where(name: permission_set_name).first_or_initialize
      permission_set.description = description
      permissions.each do |permission|
        unless permission_set.permissions.include? permission
          permission_set.permissions << permission
        end
      end
      permission_set.display_permission = display_permission
      permission_set.save!
      permission_set
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
      admin_permission = make_permission('can-manage-all', 0)
      admin_permission_set = make_permission_set([admin_permission], 'admin', 'Can manage everything')
      create_role_with_permission_sets([admin_permission_set], 'admin')

      default_permission = make_permission('default-permissions', 1)
      default_permission_set = make_permission_set([default_permission], 'default', 'Permission for general users including the customers')
      default_role = create_role_with_permission_sets([default_permission_set], 'default')
      default_role.is_default = true
      default_role.save!
    end

    task populate_other_roles: :environment do
      default_permission_set = Spree::PermissionSet.find_by(name: 'default')
      product_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/products', 3), make_permission('can-index-spree/products', 3)],
        'product_display',
        'Can view product information',
        display_permission: true
      )
      product_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/products', 3), make_permission('can-update-spree/products', 3)],
        'product_editing',
        'Can edit or create product details'
      )

      user_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/users', 3), make_permission('can-index-spree/users', 3)],
        'user_display',
        'Can view user information',
        display_permission: true
      )
      user_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/users', 3), make_permission('can-update-spree/users', 3)],
        'user_editing',
        'Can edit or create user details'
      )

      order_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/orders', 3), make_permission('can-index-spree/orders', 3)],
        'order_display',
        'Can view order information',
        display_permission: true
      )
      order_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/orders', 3), make_permission('can-update-spree/orders', 3)],
        'order_editing',
        'Can edit or create order details'
      )

      stock_location_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/stock_locations', 3), make_permission('can-index-spree/stock_locations', 3)],
        'stock_location_display',
        'Can view stock_location information',
        display_permission: true
      )
      stock_location_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/stock_locations', 3), make_permission('can-update-spree/stock_locations', 3)],
        'stock_location_editing',
        'Can edit or create stock_location details'
      )

      taxon_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/taxons', 3), make_permission('can-index-spree/taxons', 3)],
        'taxon_display',
        'Can view taxon information',
        display_permission: true
      )
      taxon_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/taxons', 3), make_permission('can-update-spree/taxons', 3)],
        'stock_location_editing',
        'Can edit or create stock_location details'
      )

      taxonomie_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/taxonomies', 3), make_permission('can-index-spree/taxonomies', 3)],
        'taxonomie_display',
        'Can view taxonomie information',
        display_permission: true
      )
      taxonomie_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/taxonomies', 3), make_permission('can-update-spree/taxonomies', 3)],
        'stock_location_editing',
        'Can edit or create stock_location details'
      )
      image_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/images', 3), make_permission('can-index-spree/images', 3)],
        'image_display',
        'Can view image information',
        display_permission: true
      )
      image_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/images', 3), make_permission('can-update-spree/images', 3)],
        'stock_location_editing',
        'Can edit or create stock_location details'
      )
      stock_display_permission_set = make_permission_set(
        [make_permission('can-read-spree/stocks', 3), make_permission('can-index-spree/stocks', 3)],
        'stock_display',
        'Can view stock information',
        display_permission: true
      )
      stock_edit_permission_set = make_permission_set(
        [make_permission('can-create-spree/stocks', 3), make_permission('can-update-spree/stocks', 3)],
        'stock_location_editing',
        'Can edit or create stock_location details'
      )

      create_role_with_permission_sets(
        [
          default_permission_set, product_display_permission_set,
          product_edit_permission_set, user_display_permission_set,
          user_edit_permission_set, order_display_permission_set,
          order_edit_permission_set
        ],
        'manager'
      )

      create_role_with_permission_sets(
        [
          default_permission_set, order_display_permission_set,
          order_edit_permission_set, user_display_permission_set
        ],
        'customer_service'
      )

      create_role_with_permission_sets(
        [
          default_permission_set, stock_display_permission_set,
          stock_edit_permission_set
        ],
        'warehouse'
      )

    end
  end
end
