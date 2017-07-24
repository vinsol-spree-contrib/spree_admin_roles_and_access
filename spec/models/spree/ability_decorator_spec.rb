require 'spec_helper'
require 'cancan/matchers'

RSpec.describe Spree::Ability, type: :model do
  let(:permission0) { Spree::Permission.create(title: 'default-admin-permissions', priority: 0) }
  let(:permission1) { Spree::Permission.create(title: 'default-permissions', priority: 0) }
  let(:permission2) { Spree::Permission.create(title: 'can-manage-all', priority: 1) }

  let(:permission3) { Spree::Permission.create(title: 'can-manage-spree/products', priority: 2) }
  let(:permission4) { Spree::Permission.create(title: 'can-manage-spree/orders', priority: 2) }
  let(:permission5) { Spree::Permission.create(title: 'can-manage-spree/users', priority: 2) }

  let(:permission6) { Spree::Permission.create(title: 'can-read-spree/users', priority: 3) }
  let(:permission7) { Spree::Permission.create(title: 'can-index-spree/users', priority: 3) }
  let(:permission8) { Spree::Permission.create(title: 'can-update-spree/users', priority: 3) }
  let(:permission9) { Spree::Permission.create(title: 'can-create-spree/users', priority: 3) }

  let(:permission10) { Spree::Permission.create(title: 'can-read-spree/orders', priority: 3) }
  let(:permission11) { Spree::Permission.create(title: 'can-index-spree/orders', priority: 3) }
  let(:permission12) { Spree::Permission.create(title: 'can-update-spree/orders', priority: 3) }
  let(:permission13) { Spree::Permission.create(title: 'can-create-spree/orders', priority: 3) }

  let(:permission14) { Spree::Permission.create(title: 'can-read-spree/products', priority: 3) }
  let(:permission15) { Spree::Permission.create(title: 'can-index-spree/products', priority: 3) }
  let(:permission16) { Spree::Permission.create(title: 'can-update-spree/products', priority: 3) }
  let(:permission17) { Spree::Permission.create(title: 'can-create-spree/products', priority: 3) }
  let(:permission_set) { Spree::PermissionSet.create!(name: 'test') }

  let(:user) { Spree::User.create!(email: 'abc@test.com', password: '123456') }
  let(:role) { Spree::Role.where(name: 'user').first_or_create! }
  let(:roles) { [role] }

  before(:each) do
    permission_set.permissions = [permission1, permission9]
    role.permission_sets << permission_set
    user.roles << role
  end

  shared_examples_for 'access granted' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { expect(subject).to be_able_to(:read, resource) }
    it { expect(subject).to be_able_to(:create, resource) }
    it { expect(subject).to be_able_to(:update, resource) }
  end

  shared_examples_for 'access denied' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { expect(subject).to_not be_able_to(:read, resource) }
    it { expect(subject).to_not be_able_to(:create, resource) }
    it { expect(subject).to_not be_able_to(:update, resource) }
  end

  shared_examples_for 'index allowed' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { expect(subject).to be_able_to(:index, resource) }
  end

  shared_examples_for 'no index allowed' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { expect(subject).to_not be_able_to(:index, resource) }
  end

  shared_examples_for 'create only' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { expect(subject).to be_able_to(:create, resource) }
    it { expect(subject).to_not be_able_to(:read, resource) }
    it { expect(subject).to_not be_able_to(:update, resource) }

    it { expect(subject).to_not be_able_to(:index, resource) }
  end

  shared_examples_for 'read only' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { expect(subject).to_not be_able_to(:create, resource) }
    it { expect(subject).to_not be_able_to(:update, resource) }
  end

  shared_examples_for 'default admin permissions' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { expect(subject).to be_able_to :admin, ::Spree::Store }
  end

  describe 'for general resource' do
    let(:resource) { Object.new }

    context 'with admin user' do
      let(:role1) { Spree::Role.where(name: 'admin').first_or_create! }
      let(:roles) { [role1] }

      before(:each) do
        permission_set.permissions = [permission2]
        role1.permission_sets << permission_set
        user.roles = roles

      end
      it_should_behave_like 'access granted'
      it_should_behave_like 'index allowed'
      it_should_behave_like 'default admin permissions'
    end

    context 'with customer_care user' do
      let(:role1) { Spree::Role.where(name: 'customer_care').first_or_create }
      let(:new_ability) { Spree::Ability.new(user) }

      before(:each) do
        permission_set.permissions = [permission4, permission6, permission7, permission0]
        role1.permission_sets << permission_set
        user.roles = roles
      end

      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'default admin permissions'
      it { expect(new_ability).to_not be_able_to :create, Spree::User, :role_ids }
      it { expect(new_ability).to_not be_able_to :update, Spree::User, :role_ids }
    end

    context 'with warehouse_admin user' do
      let(:role1) { Spree::Role.find_or_create_by(name: 'warehouse_admin') }

      before(:each) do
        permission_set.permissions = [permission10, permission11, permission12, permission0]
        role1.permission_sets << permission_set
        user.roles = roles
      end

      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'default admin permissions'
    end

    context 'with purchasing_admin user' do
      before(:each) do
        role1 = Spree::Role.find_or_create_by(name: 'purchasing_admin')
        permission_set.permissions = [permission14, permission15, permission16, permission0]
        role1.permission_sets << permission_set
        user.roles = [role1]
      end

      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'default admin permissions'
    end

    context 'with user or customer' do
      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
    end
  end

  context 'for admin protected resources' do
    let(:resource) { Object.new }
    let(:resource_shipment) { Spree::Shipment.new }
    let(:resource_product) { Spree::Product.new }
    let(:resource_user) { Spree::User.new }
    let(:resource_order) { Spree::Order.new }
    let(:fakedispatch_user) { Spree::User.new }
    let(:admin_role) { Spree::Role.where(name: 'admin').first_or_create! }
    let(:user1) { Spree::User.new }
    let(:ability) { Spree::Ability.new(user) }

    context 'with admin user' do
      before(:each) do
        permission_set.permissions = [permission2]
        admin_role.permission_sets << permission_set
        user.roles = [admin_role]
        user1.roles = [admin_role]
      end

      subject { ability }

      it { expect(subject).to be_able_to :manage, resource_order }
      it { expect(subject).to be_able_to :manage, resource_product }
      it { expect(subject).to be_able_to :manage, resource_user }

      [:update, :create, :destroy].each do |action|
        it { expect(subject).to be_able_to action, user1 }
      end
      it { expect(subject).to be_able_to :update, user }
    end

    context 'with customer_care user' do
      let(:role1) { Spree::Role.where(name: 'customer_care').first_or_create! }
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        permission_set.permissions = [permission4, permission6, permission7]
        role1.permission_sets << permission_set
        user.roles = [role1]
      end

      subject { ability }


      it { expect(subject).to be_able_to :read, resource_user }
      it { expect(subject).to be_able_to :index, resource_user }
    end

    context 'with purchasing_admin user' do
      let(:role1) { Spree::Role.where(name: 'purchasing_admin').first_or_create! }
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        permission_set.permissions = [permission14, permission15, permission16]
        role1.permission_sets << permission_set
        user.roles = [role1]
      end

      subject { ability }

      it { expect(subject).to be_able_to :index, Spree::Product.new }
      it { expect(subject).to be_able_to :update, Spree::Product.new }
      it { expect(subject).to be_able_to :read, Spree::Product.new }
    end

    context 'with warehouse_admin user' do
      let(:role1) { Spree::Role.where(name: 'warehouse_admin').first_or_create! }
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        permission_set.permissions = [permission10, permission11, permission12]
        role1.permission_sets << permission_set
        user.roles = [role1]
      end

      subject { ability }

      it { expect(subject).to be_able_to :index, resource_order }
      it { expect(subject).to be_able_to :update, resource_order }
      it { expect(subject).to be_able_to :read, resource_order }
    end

    context 'with customer' do
      let(:ability) { Spree::Ability.new(user) }

      subject { ability }

      it { expect(subject).to_not be_able_to :manage, resource }
      it { expect(subject).to_not be_able_to :manage, resource_order }
      it { expect(subject).to_not be_able_to :manage, resource_product }
      it { expect(subject).to_not be_able_to :manage, resource_user }
    end
  end

  describe 'for User' do
    context 'requested by same user' do
      let(:resource) { user }
      it_should_behave_like 'access granted'
    end
    context 'requested by other user' do
      let(:resource) { Spree::User.new }
      it_should_behave_like 'create only'
    end
  end

  describe 'for Order' do
    let(:resource) { Spree::Order.new }

    context 'requested by same user' do
      before(:each) { resource.user = user }
      it_should_behave_like 'access granted'
    end

    context 'requested by other user' do
      before(:each) { resource.user = Spree::User.new }
      it_should_behave_like 'create only'
    end

    context 'requested with inproper token' do
      let(:token) { 'FAIL' }
      before(:each) { allow(resource).to receive(:token).and_return('TOKEN123') }
      it_should_behave_like 'create only'
    end
  end

  describe 'for Product' do
    let(:resource) { Spree::Product.new }

    it_should_behave_like 'read only'
  end

  describe 'for Taxons' do
    let(:resource) { Spree::Taxon.new }

    it_should_behave_like 'read only'
  end

  describe 'initialize' do
    before(:each) do
      allow(user).to receive(:roles).and_return(roles)
      allow(roles).to receive(:includes).and_return(roles)
    end

    it 'should receive clear_aliased_actions and call original' do
      expect_any_instance_of(Spree::Ability).to receive(:clear_aliased_actions).and_call_original
      Spree::Ability.new(user)
    end

    describe 'alias_action' do
      before(:each) do
        allow_any_instance_of(Spree::Ability).to receive(:alias_action).and_return(true)
        allow_any_instance_of(Spree::Ability).to receive(:ability).and_return(true)
      end

      [[:edit, to: :update], [:new, to: :create], [:new_action, to: :create], [:show, to: :read]].each do |from, to|
        it "should receive alias_action with #{from}, #{to} on ability" do
          expect_any_instance_of(Spree::Ability).to receive(:alias_action).with(from, to).and_return(true)
          Spree::Ability.new(user)
        end
      end
    end

    it 'should receive new on Spree::User when there is no user passed' do
      expect(Spree::User).to receive(:new).and_return(user)
      Spree::Ability.new(nil)
    end

    it 'should not receive new on Spree::User when there is no user passed' do
      expect(Spree::User).to_not receive(:new)
      Spree::Ability.new(user)
    end

    it 'should_receive roles and return roles' do
      expect(user).to receive(:roles).and_return(roles)
      Spree::Ability.new(user)
    end

    it 'should_receive include_permissions on roles' do
      expect(user.roles).to receive(:includes).with(:permissions).and_return(roles)
      Spree::Ability.new(user)
    end

    it 'should receive abilities on Spree::Ability' do
      expect(Spree::Ability).to receive(:abilities).and_call_original
      Spree::Ability.new(user)
    end

    describe 'can-create-spree/users and can-update-spree/users' do
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        permission_set.permissions = [permission8, permission9]
        role.permission_sets << permission_set
      end

      subject { ability }

      it { expect(subject).to be_able_to :create, Spree::User.new }
      it { expect(subject).to be_able_to :update, Spree::User.new }
      it { expect(subject).to_not be_able_to :create, Spree::User.new, :role_ids }
      it { expect(subject).to_not be_able_to :update, Spree::User.new, :role_ids }
    end
  end

  describe 'CanCan Ability' do
    let(:rule) { CanCan::Rule.new(true, :manage, :all) }
    let(:ability) { Spree::Ability.new(user) }
    let(:rules) { [rule] }

    describe 'can' do
      before(:each) do
        allow(CanCan::Rule).to receive(:new).and_return(rule)
      end

      it 'should receive new on CanCan::Rule with true, :manage, :all' do
        expect(CanCan::Rule).to receive(:new).with(true, :manage, :all).and_return(rule)
        ability.can(:manage, :all)
      end
    end

    describe 'cannot' do
      let(:rule) { CanCan::Rule.new(false, :manage, :all) }
      let(:rules) { [rule] }

      before(:each) do
        allow(CanCan::Rule).to receive(:new).and_return(rule)
      end

      it 'should receive new on CanCan::Rule with false, :manage, :all' do
        expect(CanCan::Rule).to receive(:new).with(false, :manage, :all).and_return(rule)
        ability.cannot(:manage, :all)
      end
    end

    describe 'can?' do
      before(:each) do
        allow(ability).to receive(:relevant_rules_for_match).and_return(rules)
        allow(rule).to receive(:matches_condition?).and_return(true)
      end

      it 'should recieve relevant_rules_for_match and return rule' do
        expect(ability).to receive(:relevant_rules_for_match).with(:manage, :all, nil).and_return(rules)
        ability.can?(:manage, :all)
      end

      it 'should receive matches_condition? on with :manage, :all and return true' do
        expect(rule).to receive(:matches_conditions?).with(:manage, :all, nil).and_return(true)
        ability.can?(:manage, :all)
      end

      context 'when there is no match' do
        before(:each) do
          allow(ability).to receive(:relevant_rules_for_match).and_return([])
        end

        it 'should return false' do
          expect(ability).to_not be_able_to :manage, :all
        end
      end

      context 'when there is a match' do
        it 'should return @Match.base_behaviour' do
          expect(ability).to be_able_to :manage, :all
        end
      end
    end

    describe 'relevant_rules_for_match' do
      before(:each) do
        allow(ability).to receive(:relevant_rules).and_return(rules)
        allow(rule).to receive(:only_raw_sql?).and_return(false)
      end

      it 'should receive relevant_rules and return rules' do
        expect(ability).to receive(:relevant_rules).with(:manage, :all, nil).and_return(rules)
        ability.relevant_rules_for_match(:manage, :all)
      end

      it 'should return only_raw_sql? on rule' do
        expect(rule).to receive(:only_raw_sql?).and_return(false)
        ability.relevant_rules_for_match(:manage, :all)
      end

      it 'should return rules' do
        expect(ability.relevant_rules_for_match(:manage, :all)).to eq(rules)
      end

      context 'when only_raw_sql? returns true' do
        before(:each) do
          allow(rule).to receive(:only_raw_sql?).and_return(true)
        end

        it 'should raise Error' do
          expect { ability.relevant_rules_for_match(:manage, :all) }.to raise_error(::Exception, "The can? and cannot? call cannot be used with a raw sql 'can' definition. The checking code cannot be determined for :manage :all")
        end
      end

      context 'when only_raw_sql? returns false' do
        before(:each) do
          allow(rule).to receive(:only_raw_sql?).and_return(false)
        end

        it 'should raise Exception' do
          expect { ability.relevant_rules_for_match(:manage, :all) }.to_not raise_error
          ability.relevant_rules_for_match(:manage, :all)
        end
      end
    end

    describe 'relevant_rules' do
      before(:each) do
        allow(ability).to receive(:rules).and_return(rules)
      end

      it 'should receive expand_action with [:manage]' do
        expect(ability).to receive(:expand_actions).with([:manage]).and_return([:manage])
        ability.relevant_rules(:manage, :all)
      end

      it 'should receive relevant? with :manage, :all, nil' do
        expect(rule).to receive(:relevant?).with(:manage, :all, nil).and_return([:all])
        ability.relevant_rules(:manage, :all)
      end

      it 'should return rules' do
        expect(ability.relevant_rules(:manage, :all)).to eq(rules)
      end
    end
  end

  describe 'CanCan::Rule' do

    let(:rule) { CanCan::Rule.new(true, :manage, :all, :title) }
    let(:rule2) { CanCan::Rule.new(true, :manage, :all) }
    let(:ability) { Spree::Ability.new(user) }
    let(:rules) { [rule] }

    describe 'initialize' do
      it 'should have @match_all as false' do
        expect(rule.instance_variable_get('@match_all')).to  eq(false)
      end

      it 'should have @base_behaviour as true' do
        expect(rule.instance_variable_get('@base_behavior')).to  eq(true)
      end

      it 'should have @actions as [:all]' do
        expect(rule.instance_variable_get('@actions')).to  eq([:manage])
      end

      it 'should have @subject as [:manage]' do
        expect(rule.instance_variable_get('@subjects')).to  eq([:all])
      end

      it 'should have @attributes as [:title]' do
        expect(rule.instance_variable_get('@attributes')).to  eq([:title])
      end

      it 'should have @conditions as {}' do
        expect(rule.instance_variable_get('@conditions')).to  eq({})
      end

      it 'should have @block as nil' do
        expect(rule.instance_variable_get('@block')).to  eq(nil)
      end
    end

    describe 'attributes?' do
      context 'when there is @attributes' do
        it 'should return true' do
          expect(rule).to be_attributes
        end
      end

      context 'when there is @attributes' do
        it 'should return true' do
          expect(rule2).to_not be_attributes
        end
      end
    end

    describe 'relevant?' do

      let(:rule3) { CanCan::Rule.new(true, :read, Spree::Order) }

      before(:each) do
        rule3.instance_variable_set('@expanded_actions', [:read])
      end

      it 'should return true with :read, Spree::Order' do
        expect(rule3).to be_relevant :read, Spree::Order
      end

      it 'should return true with :read, Spree::Product' do
        expect(rule3).to_not be_relevant :read, Spree::Product
      end

      it 'should receive matches_action? with action' do
        expect(rule3).to receive(:matches_action?).with(:read).and_return(true)
        rule3.relevant?(:read, Spree::Order)
      end

      it 'should receive matches_subject? with subject' do
        expect(rule3).to receive(:matches_subject?).with(Spree::Order).and_return(true)
        rule3.relevant?(:read, Spree::Order)
      end

      it 'should receive matches_action? with action' do
        expect(rule3).to receive(:matches_attribute?).with(nil).and_return(true)
        rule3.relevant?(:read, Spree::Order)
      end

      describe 'matches_attributes?' do
        let(:rule4) { CanCan::Rule.new(true, :read, Spree::Order, :name) }

        context 'attribute is a nil' do
          it 'should return true' do
            expect(rule3).to be_relevant :read, Spree::Order, nil
          end
        end

        context 'attribute is a symbol' do
          it 'should return true when it is relevant' do
            expect(rule3).to be_relevant :read, Spree::Order, :name
          end

          it 'should return false when it is not relevant' do
            expect(rule3).to be_relevant :read, Spree::Order, :fakename
          end
        end

        context 'attribute is an array' do
          it 'should return true when it is relevant' do
            expect(rule3).to be_relevant :read, Spree::Order, [:name]
          end

          it 'should return false when it is not relevant' do
            expect(rule3).to be_relevant :read, Spree::Order, [:fakename]
          end
        end
      end

      describe 'matches_conditions?' do
        let(:rule11) { CanCan::Rule.new(true) }
        let(:block) { Proc.new { true } }
        let(:rule12)  { CanCan::Rule.new(true, :read, Spree::Order) }
        let(:rule13) { CanCan::Rule.new(true, :read, Spree::Product => Spree::Order, name: 'vijay') }
        let(:rule14) { CanCan::Rule.new(true, :read, Spree::Order, name: 'vijay') }
        let(:order) { Spree::Order.new }

        before(:each) do
          rule12.instance_variable_set('@block', block)
        end

        it 'should receive callblock_with_all on rule11' do
          expect(rule11).to receive(:call_block_with_all).with(:read, Spree::Order)
          rule11.matches_conditions?(:read, Spree::Order)
        end

        it 'should receive call on rule12' do
          expect(block).to receive(:call).with(order, :title)
          rule12.matches_conditions?(:read, order, :title)
        end

        it 'should receive nested_subject_matches_conditions? on rule13' do
          expect(rule13).to receive(:nested_subject_matches_conditions?).with(order: Spree::Product)
          rule13.matches_conditions?(:read, order: Spree::Product)
        end

        it 'should receive matches_conditions_hash? on rule14' do
          expect(rule14).to receive(:matches_conditions_hash?).with(order)
          rule14.matches_conditions?(:read, order)
        end
      end
    end
  end

  describe 'user_roles' do
    let(:ability) { Spree::Ability.new(user) }

    context 'when there is role' do
      let(:role) { Spree::Role.where(name: 'admin').first_or_create! }
      let(:roles) { [role] }

      before(:each) do
        user.roles = roles
        allow(user).to receive(:roles).and_return(roles)
        allow(roles).to receive(:includes).and_return(roles)
      end

      it 'should not receive default_role on Spree::Role' do
        expect(Spree::Role).to_not receive(:default_role)
        ability.user_roles(user)
      end

      it 'should receive roles on user' do
        expect(user).to receive(:roles).and_return(roles)
        ability.user_roles(user)
      end

      it 'should receive includes with permissions on roles' do
        expect(roles).to receive(:includes).with(:permissions).and_return(roles)
        ability.user_roles(user)
      end

      it 'should return roles on call on roles' do
        expect(ability.user_roles(user)).to  eq(roles)
      end
    end

    context 'when there is no role' do
      let(:role) { Spree::Role.where(name: 'user').first_or_create! }
      let(:roles) { [role] }
      let(:empty_roles) { [] }

      before(:each) do
        role.is_default = true
        role.save!
        user.roles = empty_roles
        allow(Spree::Role).to receive(:default_role).and_return(roles)
        allow(roles).to receive(:includes).and_return(roles)
        allow(user).to receive(:roles).and_return(empty_roles)
        allow(empty_roles).to receive(:includes).and_return(empty_roles)
      end

      it 'should receive roles on user' do
        expect(user).to receive(:roles).and_return(empty_roles)
        ability.user_roles(user)
      end

      it 'should receive includes with permissions on empty_roles' do
        expect(empty_roles).to receive(:includes).with(:permissions).and_return(empty_roles)
        ability.user_roles(user)
      end

      it 'should receive default_role on Spree::Role' do
        expect(Spree::Role).to receive(:default_role).and_return(roles)
        ability.user_roles(user)
      end

      it 'should receive includes with permissions and return roles' do
        expect(roles).to receive(:includes).with(:permissions).and_return(roles)
        ability.user_roles(user)
      end

      it 'should return roles on call on roles' do
        expect(ability.user_roles(user)).to eq(roles)
      end
    end
  end

  describe 'alias_action' do
    let(:ability) { Spree::Ability.new(user) }

    it 'should eq {update: [:edit], create: [:new, :new_action], read: [:show, :index], destroy: [:delete]}' do
      expect(ability.aliased_actions).to eq({update: [:edit], create: [:new, :new_action], read: [:show, :index], destroy: [:delete]})
    end
  end
end
