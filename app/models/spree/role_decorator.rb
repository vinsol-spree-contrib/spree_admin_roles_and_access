Spree::Role.class_eval do

  has_many :roles_permission_sets
  has_many :permission_sets, through: :roles_permission_sets
  has_many :permissions, through: :permission_sets

  validates :name, uniqueness: true, allow_blank: true
  validates :permission_sets, length: { minimum: 1, too_short: Spree.t(:atleast_one_permission_set_is_required) }

  def ability(current_ability, user)
    permissions.each do |permission|
      permission.ability(current_ability, user)
    end
  end

  def has_permission?(permission_title)
    permissions.pluck(:title).include?(permission_title)
  end

  scope :default_role, lambda { where(is_default: true) }
end
