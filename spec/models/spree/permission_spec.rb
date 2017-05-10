require 'spec_helper'

RSpec.describe Spree::Permission, type: :model do

  let(:user) { Spree::User.create!(email: 'abc@test.com', password: 'password') }
  let(:ability) { Spree::Ability.new(user) }
  let(:permission1) { Spree::Permission.create!(title: 'can-manage-all', priority: 5) }
  let(:permission2) { Spree::Permission.create!(title: 'can-update-all', priority: 2) }

  describe 'Association' do
    it { expect(subject).to have_and_belong_to_many(:legacy_roles).class_name('Spree::Role') }
    it { is_expected.to have_many(:permissions_permission_sets).dependent(:destroy) }
    it { is_expected.to have_many(:permission_sets).through(:permissions_permission_sets) }
  end

  describe 'visible' do
    before(:each) do
      permission1.visible = true
      permission1.save!
    end

    it 'should return only permissions with visible true' do
      expect(Spree::Permission.visible).to eq([permission1])
    end
  end

  describe 'Validation' do
    subject { permission1 }
    it { expect(subject).to validate_presence_of :title }
    it { expect(subject).to validate_uniqueness_of :title }
  end

  describe 'include' do
    it "should include SpreeMyLayouts::Permissions" do
      expect(Spree::Permission.ancestors.include?(Spree::Permissions)).to  eq(true)
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
      expect(Spree::Permission.all).to  eq([permission2, permission1])
    end
  end

  describe 'ability' do
    before(:each) do
      allow(permission1).to receive(:send).and_return(true)
    end

    it 'should recieve a method which has the product title as method' do
      expect(permission1).to receive(:send).with('can-manage-all', ability, user).and_return(true)
      permission1.ability(ability, user)
    end
  end

  describe 'permissions' do
    let(:permission3) { Spree::Permission.create!(title: "can-read-all", priority: 2) }
    let(:permission31) { Spree::Permission.create!(title: "cannot-read-all", priority: 2) }

    it 'should create a method of same as title' do
      expect(permission3).to_not be_respond_to('can-read-all')
      permission3.send('can-read-all', ability, user)
      expect(permission3).to  be_respond_to('can-read-all')
    end

    it 'should receive find_action_and_subject' do
      expect(permission31).to receive(:find_action_and_subject).with(:'cannot-read-all').and_return([:cannot, :read, :all])
      permission31.send('cannot-read-all', ability, user)
    end

    context 'when there is no attribute' do

      let(:permission4) { Spree::Permission.create!(title: "can-read-all", priority: 2) }

      it 'should receive can with :read, :all' do
        expect(ability).to receive(:can).with(:read, :all).and_return(true)
        permission4.send('can-read-all', ability, user)
      end
    end

    context 'when there is no attribute' do
      let(:permission4) { Spree::Permission.create(title: "can-read-all-title", priority: 2) }

      it 'should receive can with :read, :all, :title' do
        expect(ability).to receive(:can).with(:read, :all, :title).and_return(true)
        permission4.send('can-read-all-title', ability, user)
      end
    end


    describe 'find_action_and_subject' do
      context 'when if subject is all' do
        it 'should return can, action and all' do
          expect(permission3.send(:find_action_and_subject, 'can-read-all-title')).to  eq([:can, :read, :all, :title])
        end
      end

      context 'when if subject is model' do
        let(:permission4) { Spree::Permission.create!(title: "can-read-spree/orders-title", priority: 2) }
        let(:permission5) { Spree::Permission.create!(title: "can-read-spree/orders", priority: 2) }

        context 'when there is attribute' do
          it 'should return can, action, model and attribute' do
            expect(permission4.send(:find_action_and_subject, 'can-read-spree/orders-title')).to  eq([:can, :read, Spree::Order, :title])
          end
        end

        context 'when there is no attribute' do
          it 'should return can, action, model and nil' do
            expect(permission4.send(:find_action_and_subject, 'can-read-spree/orders')).to  eq([:can, :read, Spree::Order, nil])
          end
        end
      end

      context 'when if subject is not model' do
        let(:permission4) { Spree::Permission.create!(title: "can-read-spree/xyz-title", priority: 2) }

        it 'should return can, action and model with xyz' do
          expect(permission4.send(:find_action_and_subject, 'can-read-spree/xyz-title')).to  eq([:can, :read, 'spree/xyz', :title])
        end

        it 'should return can, action and model with spree/admin/invoices' do
          expect(permission4.send(:find_action_and_subject, 'can-read-spree/admin/invoices')).to  eq([:can, :read, 'spree/admin/invoices', nil])
        end
      end
    end
  end
end
