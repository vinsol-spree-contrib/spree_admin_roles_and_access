require 'spec_helper'

RSpec.describe Spree.user_class, type: :model do
  describe 'Association' do
    it { expect(subject).to have_and_belong_to_many(:roles).class_name('Spree::Role') }
  end
end