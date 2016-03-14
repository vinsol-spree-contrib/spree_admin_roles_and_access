require 'spec_helper'

RSpec.describe Spree.user_class, type: :model do
  describe 'Association' do
    it { expect(subject).to have_many(:spree_role_users).class_name('Spree::RoleUser') }
    it { expect(subject).to have_many(:roles).through(:spree_role_users).class_name('Spree::Role') }
  end
end
