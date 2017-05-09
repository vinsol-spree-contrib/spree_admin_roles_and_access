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

    def permission_prefix_from_name(name)
      case name
      when :admin
        'can-admin'
      when :new
        'can-create'
      when :show
        'can-read'
      when :delete
        'can-delete'
      when :index
        'can-index'
      when :update
        'can-update'
      when :manage
        'can-manage'
      else
        "can-#{ name }"
      end
    end

    def make_grouped_permission_set(permission_group, permission_set_name, description, display: false)
      permissions = permission_group.collect do |resource_name, permission_names|
        permission_names.collect { |permission_name| make_permission("#{ permission_prefix_from_name(permission_name) }-#{ resource_name }", 3) }
      end.flat_map
      ps = make_permission_set(
        permissions,
        permission_set_name,
        description
      )
      if display
        ps.display_permission = display
        ps.save!
      end
      ps
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
      admin_role = create_role_with_permission_sets([admin_permission_set], 'admin')
      admin_role.admin_accessible = true
      admin_role.save!
    end

    def build_permission_group(permission_list)
      group = {}
      permission_list.each_slice(2) do |permissions, resource_class|
        group[resource_class.to_s.underscore.pluralize] = permissions
      end
      group
    end

    task populate_permission_sets: :environment do
      config_display = make_grouped_permission_set(
        build_permission_group(
          [
            [:read, :admin], Spree::TaxCategory,
            [:read, :admin], Spree::TaxRate,
            [:read, :admin], Spree::Zone,
            [:read, :admin], Spree::Country,
            [:read, :admin], Spree::State,
            [:read, :admin], Spree::PaymentMethod,
            [:read, :admin], Spree::Taxonomy,
            [:read, :admin], Spree::ShippingMethod,
            [:read, :admin], Spree::ShippingCategory,
            [:read, :admin], Spree::StockLocation,
            [:read, :admin], Spree::StockMovement,
            [:read, :admin], Spree::RefundReason,
            [:read, :admin], Spree::ReimbursementType,
            [:edit, :admin], 'Spree::GeneralSetting'
          ]
        ),
        "Configuration Display",
        "Display Configuration of the store",
        display: true
      )



      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :manage], Spree::TaxCategory,
            [:admin, :manage], Spree::TaxRate,
            [:admin, :manage], Spree::Zone,
            [:admin, :manage], Spree::Country,
            [:admin, :manage], Spree::State,
            [:admin, :manage], Spree::PaymentMethod,
            [:admin, :manage], Spree::Taxonomy,
            [:admin, :manage], Spree::ShippingMethod,
            [:admin, :manage], Spree::ShippingCategory,
            [:admin, :manage], Spree::StockLocation,
            [:admin, :manage], Spree::StockMovement,
            [:admin, :manage], Spree::RefundReason,
            [:admin, :manage], Spree::ReimbursementType,
          ]
        ),
        "Configuration Management",
        "Manage Configuration of the store"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:read, :admin, :edit, :cart], Spree::Order,
            [:read, :admin], Spree::Payment,
            [:read, :admin], Spree::Shipment,
            [:read, :admin], Spree::Adjustment,
            [:read, :admin], Spree::LineItem,
            [:read, :admin], Spree::ReturnAuthorization,
            [:read, :admin], Spree::CustomerReturn,
            [:read, :admin], Spree::Reimbursement,
            [:read, :admin], Spree::ReturnItem,
            [:read, :admin], Spree::Refund
          ]
        ),
        "Order Display",
        "Display Orders",
        display: true
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :read], Spree::ReimbursementType,
            [:admin, :manage], Spree::Order,
            [:admin, :manage], Spree::Payment,
            [:admin, :manage], Spree::Shipment,
            [:admin, :manage], Spree::Adjustment,
            [:admin, :manage], Spree::LineItem,
            [:admin, :manage], Spree::ReturnAuthorization,
            [:admin, :manage], Spree::CustomerReturn,
            [:admin, :manage], Spree::Reimbursement,
            [:admin, :manage], Spree::ReturnItem,
            [:admin, :manage], Spree::Refund
          ]
        ),
        "Order Management",
        "Manage Orders"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:read, :admin, :edit], Spree::Product,
            [:read, :admin], Spree::Image,
            [:read, :admin], Spree::Variant,
            [:read, :admin], Spree::OptionValue,
            [:read, :admin], Spree::ProductProperty,
            [:read, :admin], Spree::OptionType,
            [:read, :admin], Spree::Property,
            [:read, :admin], Spree::Taxonomy,
            [:read, :admin], Spree::Taxon
          ]
        ),
        "Product Display",
        "Display Products",
        display: true
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :manage], Spree::ProductProperty,
            [:admin, :manage], Spree::OptionType,
            [:admin, :manage], Spree::Property,
            [:admin, :manage], Spree::Taxonomy,
            [:admin, :manage], Spree::Taxon,
            [:admin, :manage], Spree::Classification
          ]
        ),
        "Product Management",
        "Manage Products"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:read, :admin], Spree::PromotionRule,
            [:read, :admin], Spree::PromotionAction,
            [:read, :admin], Spree::PromotionCategory
          ]
        ),
        "Promotion Display",
        "Promotion Display",
        display: true
      )


      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :manage], Spree::Promotion,
            [:admin, :manage], Spree::PromotionRule,
            [:admin, :manage], Spree::PromotionAction,
            [:admin, :manage], Spree::PromotionCategory
          ]
        ),
        "Promotion management",
        "Promotion management"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:read, :admin], Spree::StockItem,
            [:read, :admin], Spree::StockLocation
          ]
        ),
        "Stock Display",
        "Display Stock",
        display: true
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:manage, :admin], Spree::StockItem,
            [:read, :admin], Spree::StockLocation
          ]
        ),
        "Stock Management",
        "Manage Stock"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:read, :admin], Spree::StockTransfer,
            [:read, :admin], Spree::StockLocation
          ]
        ),
        "Stock Transfer Display",
        "Stock Transfer Display",
        display: true
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :manage], Spree::StockTransfer,
            [:admin, :read], Spree::StockLocation
          ]
        ),
        "Stock Transfer Managment",
        "Stock Transfer Management"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :manage], Spree::StoreCredit
          ]
        ),
        "Store Credit Managment",
        "Store Credit Management"
      )


      user_display, user_edit, user_delete = make_resource_permission_set('spree/users')

      [
        make_permission('can-orders-spree/users', 3),
        make_permission('can-edit-spree/users', 3),
        make_permission('can-items-spree/users', 3),
        make_permission('can-addresses-spree/users', 3),
        make_permission('can-read-spree/store_credits', 3)
      ].each do |permission|
        unless user_display.permissions.include? permission
          user_display.permissions << permission
        end
      end
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
