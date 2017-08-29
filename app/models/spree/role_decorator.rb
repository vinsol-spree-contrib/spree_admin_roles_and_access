Spree::Role.class_eval do

  has_many :roles_permission_sets, dependent: :destroy
  has_many :permission_sets, through: :roles_permission_sets
  has_many :permissions, through: :permission_sets

  # DEPRECATED: Use permission sets instead. Only here for aiding migration for existing users
  has_and_belongs_to_many :legacy_permissions, join_table: 'spree_roles_permissions', class_name: 'Spree::Permission'

  validates :name, uniqueness: true, allow_blank: true
  validates :permission_sets, length: { minimum: 1, too_short: Spree.t(:atleast_one_permission_set_is_required) }, on: :update

  def has_permission?(permission_title)
    permissions.pluck(:title).include?(permission_title)
  end

  scope :default_role, lambda { where(is_default: true) }
end
