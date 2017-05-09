require 'spec_helper'

RSpec.describe Spree::PermissionSet, type: :model do

  let(:permission_set) { Spree::PermissionSet.create(name: 'ps1') }
  let(:permission)     { Spree::Permission.create(title: 'ps1', priority: 0) }

  describe 'Association' do
    it { is_expected.to have_many(:permissions_permission_sets).dependent(:destroy) }
    it { is_expected.to have_many(:permissions).through(:permissions_permission_sets) }
    it { is_expected.to have_many(:roles_permission_sets).dependent(:destroy) }
    it { is_expected.to have_many(:roles).through(:roles_permission_sets) }
  end

  describe 'Validations' do
    subject { permission_set }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }

    describe "length of permissions" do
      subject { permission_set }
      context "when no permissions are provided" do
        before do
          permission_set.permissions = []
        end
        it { is_expected.to_not be_valid }
        describe "error message" do
          subject { permission_set.valid?; permission_set.errors[:permissions] }
          it { is_expected.to eq [Spree.t(:atleast_one_permission_is_required)] }
        end
      end
      context "when permission sets provided" do
        before do
          permission_set.permissions = [permission]
        end

        it { is_expected.to be_valid }
      end
    end
  end

end
