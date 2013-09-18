require 'spec_helper'

describe Spree::Role do

  let(:user) { Spree::User.create!(:email => 'abc@test.com', :password => 'password') }
  let(:ability) { Spree::Ability.new(user) }
  let(:role1) { Spree::Role.create!(:name => 'user') { |role| role.is_default = true }}
  let(:permission1) { Spree::Permission.create!(:title => 'can-manage-all', :priority => 5) }
  let(:permission2) { Spree::Permission.create!(:title => 'can-manage-spree/orders', :priority => 2) }

  before(:each) do
    role1.permissions = [permission1, permission2]
  end
  
  describe 'Association' do
    it { should have_and_belong_to_many(:permissions).class_name('Spree::Permission') }
    it "should return permissions on the basis of ascending order of priority" do
      role1.reload.permissions.should eq([permission2, permission1])
    end
  end

  describe 'Validation' do
    it { should validate_presence_of :name }
    it { should validate_uniqueness_of :name }
  end

  describe 'mass_assignment' do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:permission_ids) }
  end

  describe 'default_role scope' do
    it "should return the role with name user" do
      Spree::Role.default_role.should eq([role1])
    end
  end

  describe 'has_permission?' do
    it "should has_permission to manage all" do
      role1.has_permission?('can-manage-all').should be_true
    end
    it "should not has_permission to manage products" do
      role1.has_permission?('can-manage-spree/products').should be_false
    end
  end

  describe 'ability' do
    before(:each) do
      @permissions = [permission1, permission2]
      role1.stub(:permissions).and_return(@permissions)
    end

    it 'should receive permissions and return @permissions' do
      role1.should_receive(:permissions).and_return(@permissions)
      role1.ability(ability, user)
    end

    it 'should receive ability on permission' do
      permission1.should_receive(:ability).with(ability, user).and_return(true)
      role1.ability(ability, user)
    end
  end
end