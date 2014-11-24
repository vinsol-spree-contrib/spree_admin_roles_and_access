require 'spec_helper'

RSpec.describe Spree::Role, type: :model  do

  let(:user) { Spree::User.create!(:email => 'abc@test.com', :password => 'password') }
  let(:ability) { Spree::Ability.new(user) }
  let(:role1) { Spree::Role.create!(:name => 'user') { |role| role.is_default = true }}
  let(:permission1) { Spree::Permission.create!(:title => 'can-manage-all', :priority => 5) }
  let(:permission2) { Spree::Permission.create!(:title => 'can-manage-spree/orders', :priority => 2) }

  before(:each) do
    role1.permissions = [permission1, permission2]
  end
  
  describe 'Association' do
    it { expect(subject).to have_and_belong_to_many(:permissions).class_name('Spree::Permission') }
    it "should return permissions on the basis of ascending order of priority" do
      expect(role1.reload.permissions).to eq([permission2, permission1])
    end
  end

  describe 'Validation' do
    it { expect(subject).to validate_presence_of :name }
    it { expect(subject).to validate_uniqueness_of :name }
  end

  describe 'default_role scope' do
    it "should return the role with name user" do
      expect(Spree::Role.default_role).to eq([role1])
    end
  end

  describe 'has_permission?' do
    it "should has_permission to manage all" do
      expect(role1.has_permission?('can-manage-all')).to  eq(true)
    end
    it "should not has_permission to manage products" do
      expect(role1.has_permission?('can-manage-spree/products')).to  eq(false)
    end
  end

  describe 'ability' do
    before(:each) do
      @permissions = [permission1, permission2]
      allow(role1).to receive(:permissions).and_return(@permissions)
    end

    it 'should receive permissions and return @permissions' do
      expect(role1).to receive(:permissions).and_return(@permissions)
      role1.ability(ability, user)
    end

    it 'should receive ability on permission' do
      expect(permission1).to receive(:ability).with(ability, user).and_return(true)
      role1.ability(ability, user)
    end
  end
end