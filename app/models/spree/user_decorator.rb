Spree.user_class.class_eval do
  has_many :spree_role_users, class_name: 'Spree::RoleUser', foreign_key: :user_id
  has_many :roles, -> { uniq }, through: :spree_role_users, class_name: 'Spree::Role', source: :role
end
