namespace :spree_roles do
  namespace :permissions do

    def description_from_title(title)
      permission = title.split('/')
      description = ["Permitted user"]
      description << permission.first.gsub('-', '_').gsub('index', 'list').gsub('_spree', '').humanize
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

    def make_resource_permission_set(resource_name)
      resource_admin_permission  = make_permission("can-admin-#{ resource_name }", 3)
      resource_read_permission   = make_permission("can-read-#{ resource_name }", 3)
      resource_index_permission  = make_permission("can-index-#{ resource_name }", 3)
      resource_update_permission = make_permission("can-update-#{ resource_name }", 3)
      resource_create_permission = make_permission("can-create-#{ resource_name }", 3)
      resource_delete_permission = make_permission("can-destroy-#{ resource_name }", 3)
      resource_human_name = resource_name.gsub('/', '').gsub('spree', '').titleize

      display = make_permission_set(
        [resource_admin_permission, resource_read_permission, resource_index_permission],
        "#{ resource_human_name  } Display",
        "Permitted user can view #{ resource_human_name }",
        display_permission: true
      )

      edit = make_permission_set(
        [resource_admin_permission, resource_update_permission, resource_create_permission],
        "#{ resource_human_name } Manage",
        "Permitted user can create or update #{ resource_human_name }"
      )

      delete = make_permission_set(
        [resource_admin_permission, resource_delete_permission],
        "#{ resource_human_name } Destroy",
        "Permitted user can delete #{ resource_human_name }"
      )

      [display, edit, delete]
    end

    desc "Create admin username and password"

    task populate: :environment do
      default_permission = make_permission('default-permissions', 0)
      default_permission_set = make_permission_set(
        [default_permission],
        'default',
        'Permission for general users including the customers, Note: *users without this permission cannot checkout*'
      )
      default_role = create_role_with_permission_sets([default_permission_set], 'default')
      default_role.is_default = true
      default_role.save!

      admin_permission = make_permission('can-manage-all', 0)
      admin_permission_set = make_permission_set([admin_permission], 'admin', 'Can manage everything')
      create_role_with_permission_sets([admin_permission_set], 'admin')
    end

    task populate_other_roles: :environment do
      default                                                            = Spree::PermissionSet.find_by(name: 'default')
      product_display, product_edit, product_delete                      = make_resource_permission_set('spree/products')
      user_display, user_edit, user_delete                               = make_resource_permission_set('spree/users')
      order_display, order_edit, order_delete                            = make_resource_permission_set('spree/orders')
      taxon_display, taxon_edit, taxon_delete                            = make_resource_permission_set('spree/taxons')
      taxonomy_display, taxonomy_edit, taxonomy_delete                   = make_resource_permission_set('spree/taxonomies')
      image_display, image_edit, image_delete                            = make_resource_permission_set('spree/images')
      stock_location_display, stock_location_edit, stock_location_delete = make_resource_permission_set('spree/stock_locations')
      stock_display, stock_edit, stock_delete                            = make_resource_permission_set('spree/stocks')

      create_role_with_permission_sets(
        [
          default,
          product_display,
          product_edit,
          user_display,
          user_edit,
          order_display,
          order_edit
        ],
        'manager'
      )

      create_role_with_permission_sets(
        [
          default,
          order_display,
          order_edit,
          user_display
        ],
        'customer_service'
      )

      create_role_with_permission_sets(
        [
          default,
          stock_display,
          stock_edit
        ],
        'warehouse'
      )
    end
  end
end
