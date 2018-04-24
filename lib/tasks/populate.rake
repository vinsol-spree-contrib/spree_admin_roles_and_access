namespace :spree_roles do
  namespace :permissions do

    def description_from_title(title)
      permission = title.split('/')
      description = ["Permitted user"]
      description << permission.first.gsub('-', '_').gsub('index', 'list').gsub('_spree', '').humanize
      description << permission.second.titleize if permission[1].present?
      description.join(" ").humanize
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
        'can-read'
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
        description.humanize
      )
      if display
        ps.display_permission = display
        ps.save!
      end
      ps
    end

    def build_permission_group(permission_list)
      group = {}
      permission_list.each_slice(2) do |permissions, resource_class|
        group[resource_class.to_s.underscore.pluralize] = permissions
      end
      group
    end

    def add_to_permission_set(permission_set, permissions)
      permissions.each do |permission|
        unless permission_set.permissions.include? permission
          permission_set.permissions << permission
        end
      end
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

    desc "Create utility permission sets for common store admin tasks"
    task populate_permission_sets: :environment do
      config_management =
        make_grouped_permission_set(
          build_permission_group(
            [
              [:admin], Spree::Store,
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
              [:admin, :manage], Spree::StockTransfer,
              [:admin, :manage], Spree::StockMovement,
              [:admin, :manage], Spree::RefundReason,
              [:admin, :manage], Spree::ReturnAuthorizationReason,
              [:admin, :manage], Spree::ReimbursementType
            ]
          ),
          "Configuration Management",
          "Manage configuration of spree store 1:1 mapping of all options available in submenu/configuration."
        )

      admin_general_settings_admin = make_permission('can-admin-spree/admin/general_settings', 3)
      admin_general_settings_manage = make_permission('can-manage-spree/admin/general_settings', 3)
      spree_config_admin = make_permission('can-admin-spree/config', 3)
      spree_config_manage = make_permission('can-manage-spree/config', 3)

      add_to_permission_set(config_management, [admin_general_settings_admin, admin_general_settings_manage, spree_config_admin, spree_config_manage])

      order_display =
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


      admin_return_idx = make_permission('can-admin-spree/admin/return_index', 3)
      manage_return_idx = make_permission('can-manage-spree/admin/return_index', 3)
      return_auth      = make_permission('can-return_authorizations-spree/admin/return_index', 3)
      customer_auth    = make_permission('can-customer_returns-spree/admin/return_index', 3)

      # Required because of access of returns
      add_to_permission_set(order_display, [admin_return_idx, return_auth, customer_auth])

      order_mgmt = make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :read], Spree::Product,
            [:admin, :read], Spree::Variant,
            [:admin, :read], Spree::ReimbursementType,
            [:admin, :read, :edit, :new], Spree::User,
            [:admin, :manage], Spree::Order,
            [:admin, :manage], Spree::Payment,
            [:admin, :manage], Spree::Shipment,
            [:admin, :manage], Spree::Adjustment,
            [:admin, :manage], Spree::LineItem,
            [:admin, :manage], Spree::ReturnAuthorization,
            [:admin, :manage], Spree::CustomerReturn,
            [:admin, :manage], Spree::Reimbursement,
            [:admin, :manage], Spree::ReturnItem,
            [:admin, :manage], Spree::Refund,
            [:admin, :manage], Spree::StateChange,
            [:admin, :manage], Spree::LogEntry
          ]
        ),
        "Order Management",
        "Manage Orders"
      )

      add_to_permission_set(order_mgmt, [admin_return_idx, manage_return_idx])

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
            [:read, :admin], Spree::Taxon,
            [:admin, :read], Spree::Classification
          ]
        ),
        "Product Display",
        "Display Products",
        display: true
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin, :manage], Spree::Product,
            [:admin, :manage], Spree::ProductOptionType,
            [:manage, :admin], Spree::Image,
            [:manage, :admin], Spree::Variant,
            [:manage, :admin], Spree::OptionValue,
            [:admin, :manage], Spree::ProductProperty,
            [:admin, :manage], Spree::OptionType,
            [:admin, :manage], Spree::Property,
            [:admin, :manage], Spree::Taxonomy,
            [:admin, :manage], Spree::Taxon,
            [:admin, :manage], Spree::Classification,
            [:admin, :manage], Spree::Prototype
          ]
        ),
        "Product Management",
        "Manage Products"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:read, :admin, :edit], Spree::Promotion,
            [:read, :admin, :edit], Spree::PromotionCategory,
            [:read, :admin], Spree::PromotionRule,
            [:read, :admin], Spree::PromotionAction,
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
            [:admin], Spree::Store,
            [:manage, :admin], Spree::Stock,
            [:manage, :admin], Spree::StockItem,
            [:manage, :admin], Spree::StockLocation,
            [:admin, :manage], Spree::StockMovement,
            [:admin, :manage], Spree::StockTransfer,
          ]
        ),
        "Stock Management",
        "Manage Stock"
      )

      make_grouped_permission_set(
        build_permission_group(
          [
            [:admin], Spree::Store,
            [:admin, :manage], Spree::StoreCreditCategory,
            [:admin, :manage], Spree::StoreCredit,
            [:admin, :read, :edit], Spree::User
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
        make_permission('can-admin-spree/store_credits', 3),
        make_permission('can-read-spree/store_credits', 3),
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

  end
end
