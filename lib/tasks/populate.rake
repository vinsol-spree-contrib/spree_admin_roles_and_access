namespace :spree_roles do
  namespace :permissions do
    desc "Create admin username and password"
    task :populate => :environment do
      admin = Spree::Role.where(:name => 'admin').first_or_create!
      user = Spree::Role.where(:name => 'user').first_or_create!
      user.is_default = true
      user.save!

      permission1 = Spree::Permission.create!(:title => 'can-manage-all', :priority => 0)
      permission2 = Spree::Permission.create!(:title => 'default-permissions', :priority => 1)

      user.permissions = [permission2]
      admin.permissions = [permission1]
    end
  end
end