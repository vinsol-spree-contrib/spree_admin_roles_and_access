require 'spec_helper'

RSpec.describe Spree::Role, type: :model  do

  let(:user) { Spree::User.create!(email: 'abc@test.com', password: 'password') }
  let(:ability) { Spree::Ability.new(user) }
  let(:role1) { Spree::Role.create!(name: 'user') { |role| role.is_default = true } }
  let(:permission1) { Spree::Permission.create!(title: 'can-manage-all', priority: 5) }
  let(:permission2) { Spree::Permission.create!(title: 'can-manage-spree/orders', priority: 2) }
  let(:permission_set) { Spree::PermissionSet.create!(name: 'test-example') }

  before(:each) do
    permission_set.permissions = [permission1, permission2]
    role1.permission_sets << permission_set
  end

  describe 'Association' do
    it { expect(subject).to have_and_belong_to_many(:legacy_permissions).class_name('Spree::Permission') }
    it { is_expected.to have_many(:roles_permission_sets).dependent(:destroy) }
    it { is_expected.to have_many(:permission_sets).through(:roles_permission_sets) }


    it "should return permissions on the basis of ascending order of priority" do
      expect(role1.reload.permissions).to eq([permission2, permission1])
    end
  end

  describe 'Validation' do
    it { expect(subject).to validate_presence_of :name }
    it { expect(subject).to validate_uniqueness_of :name }

    describe "length of permission sets" do
      subject { role1 }
      context "when no permission sets provided" do
        before do
          role1.permission_sets = []
        end
        it { is_expected.to_not be_valid }
        describe "error message" do
          subject { role1.valid?; role1.errors[:permission_sets] }
          it { pending("Translation not working"); is_expected.to eq [Spree.t(:atleast_one_permission_set_is_required)] }
        end
      end
      context "when permission sets provided" do
        it { is_expected.to be_valid }
      end
    end
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

end
