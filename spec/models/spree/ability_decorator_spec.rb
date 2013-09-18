require 'spec_helper'
require 'cancan/matchers'

describe Spree::Ability do
  let(:permission0) { Spree::Permission.create(:title => 'default-admin-permissions', :priority => 0) }
  let(:permission1) { Spree::Permission.create(:title => 'default-permissions', :priority => 0) }
  let(:permission2) { Spree::Permission.create(:title => 'can-manage-all', :priority => 1) }
  
  let(:permission3) { Spree::Permission.create(:title => 'can-manage-spree/products', :priority => 2) }
  let(:permission4) { Spree::Permission.create(:title => 'can-manage-spree/orders', :priority => 2) } 
  let(:permission5) { Spree::Permission.create(:title => 'can-manage-spree/users', :priority => 2) }
    
  let(:permission6) { Spree::Permission.create(:title => 'can-read-spree/users', :priority => 3) }
  let(:permission7) { Spree::Permission.create(:title => 'can-index-spree/users', :priority => 3) }
  let(:permission8) { Spree::Permission.create(:title => 'can-update-spree/users', :priority => 3) }
  let(:permission9) { Spree::Permission.create(:title => 'can-create-spree/users', :priority => 3) }

  let(:permission10) { Spree::Permission.create(:title => 'can-read-spree/orders', :priority => 3) }
  let(:permission11) { Spree::Permission.create(:title => 'can-index-spree/orders', :priority => 3) }
  let(:permission12) { Spree::Permission.create(:title => 'can-update-spree/orders', :priority => 3) }
  let(:permission13) { Spree::Permission.create(:title => 'can-create-spree/orders', :priority => 3) }

  let(:permission14) { Spree::Permission.create(:title => 'can-read-spree/products', :priority => 3) }
  let(:permission15) { Spree::Permission.create(:title => 'can-index-spree/products', :priority => 3) }
  let(:permission16) { Spree::Permission.create(:title => 'can-update-spree/products', :priority => 3) }
  let(:permission17) { Spree::Permission.create(:title => 'can-create-spree/products', :priority => 3) }

  let(:user) { Spree::User.create!(:email => 'abc@test.com', :password => '123456') }
  let(:role) { Spree::Role.where(:name => 'user').first_or_create! }
  let(:roles) { [role] }

  before(:each) do
    role.permissions = [permission1, permission9]
    user.roles = [role]
  end

  shared_examples_for 'access granted' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { should be_able_to(:read, resource) }
    it { should be_able_to(:create, resource) }
    it { should be_able_to(:update, resource) }
  end

  shared_examples_for 'access denied' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { should_not be_able_to(:read, resource) }
    it { should_not be_able_to(:create, resource) }
    it { should_not be_able_to(:update, resource) }
  end

  shared_examples_for 'index allowed' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { should be_able_to(:index, resource) }
  end

  shared_examples_for 'no index allowed' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { should_not be_able_to(:index, resource) }
  end

  shared_examples_for 'create only' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { should be_able_to(:create, resource) }
    it { should_not be_able_to(:read, resource) }
    it { should_not be_able_to(:update, resource) }

    it { should_not be_able_to(:index, resource) }
  end

  shared_examples_for 'read only' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }
    
    it { should_not be_able_to(:create, resource) }
    it { should_not be_able_to(:update, resource) }
  end

  shared_examples_for 'default admin permissions' do
    let(:ability) { Spree::Ability.new(user) }
    subject { ability }

    it { should be_able_to :admin, 'spree/admin/overview' }
    it { should be_able_to :index, 'spree/admin/overview' }
  end

  describe 'for general resource' do
    let(:resource) { Object.new }

    context 'with admin user' do
      let(:role1) { Spree::Role.where(:name => 'admin').first_or_create! }
      let(:roles) { [role1] }

      before(:each) do
        role1.permissions = [permission2]
        user.roles = roles
      end

      it_should_behave_like 'access granted'
      it_should_behave_like 'index allowed'
      it_should_behave_like 'default admin permissions'
    end

    context 'with customer_care user' do
      let(:role1) { Spree::Role.where(:name => 'customer_care').first_or_create }
      let(:new_ability) { Spree::Ability.new(user) }

      before(:each) do
        role1.permissions = [permission4, permission6, permission7, permission0]
        user.roles = [role1]
      end

      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'default admin permissions'
      it { new_ability.should_not be_able_to :create, Spree::User, :role_ids }
      it { new_ability.should_not be_able_to :update, Spree::User, :role_ids }
    end

    context 'with warehouse_admin user' do
      let(:role1) { Spree::Role.find_or_create_by_name('warehouse_admin') }

      before(:each) do
        role1.permissions = [permission10, permission11, permission12, permission0]
        user.roles = [role1]
      end

      it_should_behave_like 'access denied'
      it_should_behave_like 'no index allowed'
      it_should_behave_like 'default admin permissions'
    end

    context 'with purchasing_admin user' do
      before(:each) do
        role1 = Spree::Role.find_or_create_by_name('warehouse_admin')
        role1.permissions = [permission14, permission15, permission16, permission0]
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
    let(:admin_role) { Spree::Role.where(:name => 'admin').first_or_create! }
    let(:user1) { Spree::User.new }
    let(:ability) { Spree::Ability.new(user) }

    context 'with admin user' do
      before(:each) do
        admin_role.permissions = [permission2]
        user.roles = [admin_role]
        user1.roles = [admin_role]
      end

      subject { ability }

      it { should be_able_to :manage, resource_order }
      it { should be_able_to :manage, resource_product }
      it { should be_able_to :manage, resource_user }
        
      [:update, :create, :destroy].each do |action|
        it { should be_able_to action, user1 }
      end
      it { should be_able_to :update, user }
    end

    context 'with customer_care user' do
      let(:role1) { Spree::Role.where(:name => 'customer_care').first_or_create! }
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        role1.permissions = [permission4, permission6, permission7]
        user.roles = [role1]
      end

      subject { ability }

        
      it { should be_able_to :read, resource_user }
      it { should be_able_to :index, resource_user }        
    end

    context 'with purchasing_admin user' do
      let(:role1) { Spree::Role.where(:name => 'purchasing_admin').first_or_create! }
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        role1.permissions = [permission14, permission15, permission16]
        user.roles = [role1]
      end

      subject { ability }

      it { should be_able_to :index, Spree::Product.new }
      it { should be_able_to :update, Spree::Product.new }
      it { should be_able_to :read, Spree::Product.new }
    end

    context 'with warehouse_admin user' do
      let(:role1) { Spree::Role.where(:name => 'warehouse_admin').first_or_create! }
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        role1.permissions = [permission10, permission11, permission12]
        user.roles = [role1]
      end

      subject { ability }

      it { should be_able_to :index, resource_order }
      it { should be_able_to :update, resource_order }
      it { should be_able_to :read, resource_order }
    end

    context 'with customer' do
      let(:ability) { Spree::Ability.new(user) }

      subject { ability }

      it { should_not be_able_to :manage, resource }
      it { should_not be_able_to :manage, resource_order }
      it { should_not be_able_to :manage, resource_product }
      it { should_not be_able_to :manage, resource_user }
    end
  end

  describe 'for User' do
    context 'requested by same user' do
      let(:resource) { user }
      it_should_behave_like 'access granted'
      it_should_behave_like 'no index allowed'
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
      it_should_behave_like 'no index allowed'
    end

    context 'requested by other user' do
      before(:each) { resource.user = Spree::User.new }
      it_should_behave_like 'create only'
    end

    context 'requested with inproper token' do
      let(:token) { 'FAIL' }
      before(:each) { resource.stub :token => 'TOKEN123' }
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
      user.stub(:roles).and_return(roles)
      roles.stub(:includes).and_return(roles)
    end

    it 'should receive clear_aliased_actions and call original' do
      Spree::Ability.any_instance.should_receive(:clear_aliased_actions).and_call_original
      Spree::Ability.new(user)
    end

    describe 'alias_action' do
      before(:each) do
        Spree::Ability.any_instance.stub(:alias_action).and_return(true)
        Spree::Ability.any_instance.stub(:ability).and_return(true)
      end
      
      [[:edit, :to => :update], [:new, :to => :create], [:new_action, :to => :create], [:show, :to => :read]].each do |from, to|
        it "should receive alias_action with #{from}, #{to} on ability" do
          Spree::Ability.any_instance.should_receive(:alias_action).with(from, to).and_return(true)
          Spree::Ability.new(user)
        end
      end 
    end

    it 'should receive new on Spree::User when there is no user passed' do
      Spree::User.should_receive(:new).and_return(user)
      Spree::Ability.new(nil)
    end

    it 'should not receive new on Spree::User when there is no user passed' do
      Spree::User.should_not_receive(:new)
      Spree::Ability.new(user)
    end

    it 'should_receive roles and return roles' do
      user.should_receive(:roles).and_return(roles)
      Spree::Ability.new(user)
    end

    it 'should_receive include_permissions on roles' do
      user.roles.should_receive(:includes).with(:permissions).and_return(roles)
      Spree::Ability.new(user)
    end

    it 'should receive ability with role and user' do
      Spree::Ability.any_instance.should_receive(:ability).with(role, user).and_call_original
      Spree::Ability.new(user)
    end

    it 'should receive abilities on Spree::Ability' do
      Spree::Ability.should_receive(:abilities).and_call_original
      Spree::Ability.new(user)
    end

    describe 'can-create-spree/users and can-update-spree/users' do
      let(:ability) { Spree::Ability.new(user) }

      before(:each) do
        role.permissions = [permission8, permission9]
      end

      subject { ability }

      it { should be_able_to :create, Spree::User.new }
      it { should be_able_to :update, Spree::User.new }
      it { should_not be_able_to :create, Spree::User.new, :role_ids }
      it { should_not be_able_to :update, Spree::User.new, :role_ids }
    end
  end
    
  describe 'ability method' do
    let(:ability) { Spree::Ability.new(user) }

    it 'should receive ability on role with ability, user' do
      role.should_receive(:ability).with(ability, user).and_return(true)
      ability.ability(role, user)
    end
  end

  describe 'CanCan Ability' do
    let(:rule) { CanCan::Rule.new(true, :manage, :all) }
    let(:ability) { Spree::Ability.new(user) }
    let(:rules) { [rule] }
    
    describe 'can' do
      before(:each) do
        CanCan::Rule.stub(:new).and_return(rule)
      end

      it 'should receive new on CanCan::Rule with true, :manage, :all' do
        CanCan::Rule.should_receive(:new).with(true, :manage, :all).and_return(rule)
        ability.can(:manage, :all)
      end
    end

    describe 'cannot' do
      let(:rule) { CanCan::Rule.new(false, :manage, :all) }
      let(:rules) { [rule] }

      before(:each) do
        CanCan::Rule.stub(:new).and_return(rule)
      end
      
      it 'should receive new on CanCan::Rule with false, :manage, :all' do
        CanCan::Rule.should_receive(:new).with(false, :manage, :all).and_return(rule)
        ability.cannot(:manage, :all)
      end
    end

    describe 'can?' do
      before(:each) do
        ability.stub(:relevant_rules_for_match).and_return(rules)
        rule.stub(:matches_condition?).and_return(true)
      end

      it 'should recieve relevant_rules_for_match and return rule' do
        ability.should_receive(:relevant_rules_for_match).with(:manage, :all, nil).and_return(rules)
        ability.can?(:manage, :all)
      end

      it 'should receive matches_condition? on with :manage, :all and return true' do
        rule.should_receive(:matches_conditions?).with(:manage, :all, nil).and_return(true)
        ability.can?(:manage, :all)
      end

      context 'when there is no match' do
        before(:each) do
          ability.stub(:relevant_rules_for_match).and_return([])
        end

        it 'should return false' do
          ability.should_not be_able_to :manage, :all
        end
      end

      context 'when there is a match' do
        it 'should return @Match.base_behaviour' do
          ability.should be_able_to :manage, :all
        end
      end
    end

    describe 'relevant_rules_for_match' do
      before(:each) do
        ability.stub(:relevant_rules).and_return(rules)
        rule.stub(:only_raw_sql?).and_return(false)
      end

      it 'should receive relevant_rules and return rules' do
        ability.should_receive(:relevant_rules).with(:manage, :all, nil).and_return(rules)
        ability.relevant_rules_for_match(:manage, :all)
      end

      it 'should return only_raw_sql? on rule' do
        rule.should_receive(:only_raw_sql?).and_return(false)
        ability.relevant_rules_for_match(:manage, :all)
      end

      it 'should return rules' do
        ability.relevant_rules_for_match(:manage, :all).should eq(rules)
      end

      context 'when only_raw_sql? returns true' do
        before(:each) do
          rule.stub(:only_raw_sql?).and_return(true)
        end

        it 'should raise Error' do
          expect { ability.relevant_rules_for_match(:manage, :all) }.to raise_error(::Exception, "The can? and cannot? call cannot be used with a raw sql 'can' definition. The checking code cannot be determined for :manage :all")
        end
      end

      context 'when only_raw_sql? returns false' do
        before(:each) do
          rule.stub(:only_raw_sql?).and_return(false)
        end

        it 'should raise Exception' do
          expect { ability.relevant_rules_for_match(:manage, :all) }.to_not raise_error
          ability.relevant_rules_for_match(:manage, :all)
        end
      end
    end

    describe 'relevant_rules' do
      before(:each) do
        ability.stub(:rules).and_return(rules)
      end

      it 'should receive expand_action with [:manage]' do
        ability.should_receive(:expand_actions).with([:manage]).and_return([:manage])
        ability.relevant_rules(:manage, :all)
      end

      it 'should receive relevant? with :manage, :all, nil' do
        rule.should_receive(:relevant?).with(:manage, :all, nil).and_return([:all])
        ability.relevant_rules(:manage, :all)
      end

      it 'should return rules' do
        ability.relevant_rules(:manage, :all).should eq(rules)
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
        rule.instance_variable_get('@match_all').should eq(false)
      end

      it 'should have @base_behaviour as true' do
        rule.instance_variable_get('@base_behavior').should eq(true)
      end

      it 'should have @actions as [:all]' do
        rule.instance_variable_get('@actions').should eq([:manage])
      end

      it 'should have @subject as [:manage]' do
        rule.instance_variable_get('@subjects').should eq([:all])
      end

      it 'should have @attributes as [:title]' do
        rule.instance_variable_get('@attributes').should eq([:title])
      end

      it 'should have @conditions as {}' do
        rule.instance_variable_get('@conditions').should eq({})
      end

      it 'should have @block as nil' do
        rule.instance_variable_get('@block').should eq(nil)
      end
    end

    describe 'attributes?' do
      context 'when there is @attributes' do
        it 'should return true' do
          rule.should be_attributes
        end
      end

      context 'when there is @attributes' do
        it 'should return true' do
          rule2.should_not be_attributes
        end
      end
    end

    describe 'relevant?' do
      
      let(:rule3) { CanCan::Rule.new(true, :read, Spree::Order) }

      before(:each) do
        rule3.instance_variable_set('@expanded_actions', [:read])
      end

      it 'should return true with :read, Spree::Order' do
        rule3.should be_relevant :read, Spree::Order
      end

      it 'should return true with :read, Spree::Product' do
        rule3.should_not be_relevant :read, Spree::Product
      end

      it 'should receive matches_action? with action' do
        rule3.should_receive(:matches_action?).with(:read).and_return(true)
        rule3.relevant?(:read, Spree::Order)
      end

      it 'should receive matches_subject? with subject' do
        rule3.should_receive(:matches_subject?).with(Spree::Order).and_return(true)
        rule3.relevant?(:read, Spree::Order)
      end

      it 'should receive matches_action? with action' do
        rule3.should_receive(:matches_attribute?).with(nil).and_return(true)
        rule3.relevant?(:read, Spree::Order)
      end

      describe 'matches_attributes?' do
        let(:rule4) { CanCan::Rule.new(true, :read, Spree::Order, :name) }

        context 'attribute is a nil' do
          it 'should return true' do
            rule3.should be_relevant :read, Spree::Order, nil
          end
        end

        context 'attribute is a symbol' do
          it 'should return true when it is relevant' do
            rule3.should be_relevant :read, Spree::Order, :name
          end

          it 'should return false when it is not relevant' do
            rule3.should be_relevant :read, Spree::Order, :fakename
          end
        end

        context 'attribute is an array' do
          it 'should return true when it is relevant' do
            rule3.should be_relevant :read, Spree::Order, [:name]
          end

          it 'should return false when it is not relevant' do
            rule3.should be_relevant :read, Spree::Order, [:fakename]
          end
        end
      end

      describe 'matches_conditions?' do
        let(:rule11) { CanCan::Rule.new(true) }
        let(:block) { Proc.new { true } }
        let(:rule12)  { CanCan::Rule.new(true, :read, Spree::Order) }
        let(:rule13) { CanCan::Rule.new(true, :read, Spree::Product => Spree::Order, :name => 'vijay') }
        let(:rule14) { CanCan::Rule.new(true, :read, Spree::Order, :name => 'vijay') }
        let(:order) { Spree::Order.new }

        before(:each) do
          rule12.instance_variable_set('@block', block)
        end

        it 'should receive callblock_with_all on rule11' do
          rule11.should_receive(:call_block_with_all).with(:read, Spree::Order)
          rule11.matches_conditions?(:read, Spree::Order)
        end

        it 'should receive call on rule12' do
          block.should_receive(:call).with(order, :title)
          rule12.matches_conditions?(:read, order, :title)
        end

        it 'should receive nested_subject_matches_conditions? on rule13' do
          rule13.should_receive(:nested_subject_matches_conditions?).with(order => Spree::Product)
          rule13.matches_conditions?(:read, order => Spree::Product)
        end

        it 'should receive nested_subject_matches_conditions? on rule13' do
          rule14.should_receive(:matches_conditions_hash?).with(order)
          rule14.matches_conditions?(:read, order)
        end
      end
    end
  end

  describe 'user_roles' do
    let(:ability) { Spree::Ability.new(user) }

    context 'when there is role' do
      let(:role) { Spree::Role.where(:name => 'admin').first_or_create! }
      let(:roles) { [role] }

      before(:each) do
        user.roles = roles
        user.stub(:roles).and_return(roles)
        roles.stub(:includes).and_return(roles)
      end

      it 'should not receive default_role on Spree::Role' do
        Spree::Role.should_not_receive(:default_role)
        ability.user_roles(user)
      end

      it 'should receive roles on user' do
        user.should_receive(:roles).and_return(roles)
        ability.user_roles(user)
      end

      it 'should receive includes with permissions on roles' do
        roles.should_receive(:includes).with(:permissions).and_return(roles)
        ability.user_roles(user)
      end

      it 'should return roles on call on roles' do
        ability.user_roles(user).should eq(roles)
      end
    end

    context 'when there is no role' do
      let(:role) { Spree::Role.where(:name => 'user').first_or_create! }
      let(:roles) { [role] }
      let(:empty_roles) { [] }

      before(:each) do
        role.is_default = true
        role.save!
        user.roles = empty_roles
        Spree::Role.stub(:default_role).and_return(roles)
        roles.stub(:includes).and_return(roles)
        user.stub(:roles).and_return(empty_roles)
        empty_roles.stub(:includes).and_return(empty_roles)
      end

      it 'should receive roles on user' do
        user.should_receive(:roles).and_return(empty_roles)
        ability.user_roles(user)
      end

      it 'should receive includes with permissions on empty_roles' do
        empty_roles.should_receive(:includes).with(:permissions).and_return(empty_roles)
        ability.user_roles(user)
      end

      it 'should receive default_role on Spree::Role' do
        Spree::Role.should_receive(:default_role).and_return(roles)
        ability.user_roles(user)
      end

      it 'should receive includes with permissions and return roles' do
        roles.should_receive(:includes).with(:permissions).and_return(roles)
        ability.user_roles(user)
      end

      it 'should return roles on call on roles' do
        ability.user_roles(user).should eq(roles)
      end
    end
  end

  describe 'alias_action' do
    let(:ability) { Spree::Ability.new(user) }
    
    it 'should eq {:update=>[:edit], :create=>[:new, :new_action], :read=>[:show], :destroy => [:delete]}' do
      ability.aliased_actions.should eq({:update=>[:edit], :create=>[:new, :new_action], :read=>[:show], :destroy => [:delete]})
    end
  end
end