Spree::Role.class_eval do
  attr_accessible :name, :permission_ids
  
  has_and_belongs_to_many :permissions, :join_table => 'spree_roles_permissions', :class_name => 'Spree::Permission'

  validates :name, :presence => true, :uniqueness => true

  def ability(current_ability, user)
    permissions.each do |permission|
      permission.ability(current_ability, user)
    end
  end

  def has_permission?(permission_title)
    permissions.pluck(:title).include?(permission_title)
  end

  scope :default_role, where(:is_default => true) 
end