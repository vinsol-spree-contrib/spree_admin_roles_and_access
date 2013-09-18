require 'spec_helper'

describe Spree::Permission do

  let(:user) { Spree::User.create!(:email => 'abc@test.com', :password => 'password') }
  let(:ability) { Spree::Ability.new(user) }
  let(:permission1) { Spree::Permission.create!(:title => 'can-manage-all', :priority => 5) }
  let(:permission2) { Spree::Permission.create!(:title => 'can-update-all', :priority => 2) }

  describe 'Association' do
    it { should have_and_belong_to_many(:roles).class_name('Spree::Role') }
  end

  describe 'attr_accessible' do
    it { should allow_mass_assignment_of :priority }
    it { should allow_mass_assignment_of :title }
  end

  describe 'visible' do
    before(:each) do
      permission1.visible = true
      permission1.save!
    end

    it 'should return only permissions with visible true' do
      Spree::Permission.visible.should eq([permission1])
    end
  end

  describe 'Validation' do
    it { should validate_presence_of :title }
    it { should validate_uniqueness_of :title }
  end

  describe 'include' do
    it "should include SpreeMyLayouts::Permissions" do
      Spree::Permission.ancestors.include?(Spree::Permissions).should be_true
    end
  end

  describe 'default_scope' do
    before(:each) do
      # permission1, permission2 are written just naive because they are defined in let, which is lazy load.
      # So, when the query executes Spree::Permission.all no permission in defined.
      permission1
      permission2
    end

    it 'should give permissions in increase order of priority' do
      Spree::Permission.all.should eq([permission2, permission1])
    end
  end

  describe 'ability' do
    it 'should recieve a method which has the product title as method' do
      permission1.should_receive(:send).with('can-manage-all', ability, user).and_return(true)
      permission1.ability(ability, user)
    end
  end

  describe 'permissions' do
    let(:permission3) { Spree::Permission.create!(:title => "can-read-all", :priority => 2) }
    let(:permission31) { Spree::Permission.create!(:title => "cannot-read-all", :priority => 2) }
    
    it 'should create a method of same as title' do
      permission3.should_not be_respond_to('can-read-all')
      permission3.send('can-read-all', ability, user)
      permission3.should be_respond_to('can-read-all')
    end

    it 'should receive find_action_and_subject' do
      permission31.should_receive(:find_action_and_subject).with(:'cannot-read-all').and_return([:cannot, :read, :all])
      permission31.send('cannot-read-all', ability, user)
    end

    context 'when there is no attribute' do

      let(:permission4) { Spree::Permission.create!(:title => "can-read-all", :priority => 2) }

      it 'should receive can with :read, :all' do
        ability.should_receive(:can).with(:read, :all).and_return(true)
        permission4.send('can-read-all', ability, user)
      end
    end

    context 'when there is no attribute' do
      let(:permission4) { Spree::Permission.create(:title => "can-read-all-title", :priority => 2) }
      
      it 'should receive can with :read, :all, :title' do
        ability.should_receive(:can).with(:read, :all, :title).and_return(true)
        permission4.send('can-read-all-title', ability, user)
      end
    end


    describe 'find_action_and_subject' do
      context 'when if subject is all' do
        it 'should return can, action and all' do
          permission3.send(:find_action_and_subject, 'can-read-all-title').should eq([:can, :read, :all, :title])
        end
      end

      context 'when if subject is model' do
        let(:permission4) { Spree::Permission.create!(:title => "can-read-spree/orders-title", :priority => 2) }
        let(:permission5) { Spree::Permission.create!(:title => "can-read-spree/orders", :priority => 2) }
        
        context 'when there is attribute' do
          it 'should return can, action, model and attribute' do
            permission4.send(:find_action_and_subject, 'can-read-spree/orders-title').should eq([:can, :read, Spree::Order, :title])
          end
        end

        context 'when there is no attribute' do
          it 'should return can, action, model and nil' do
            permission4.send(:find_action_and_subject, 'can-read-spree/orders').should eq([:can, :read, Spree::Order, nil])
          end
        end
      end

      context 'when if subject is not model' do
        let(:permission4) { Spree::Permission.create!(:title => "can-read-spree/xyz-title", :priority => 2) }
        
        it 'should return can, action and model with xyz' do
          permission4.send(:find_action_and_subject, 'can-read-spree/xyz-title').should eq([:can, :read, 'spree/xyz', :title])
        end

        it 'should return can, action and model with spree/admin/invoices' do
          permission4.send(:find_action_and_subject, 'can-read-spree/admin/invoices').should eq([:can, :read, 'spree/admin/invoices', nil])
        end
      end
    end
  end
end