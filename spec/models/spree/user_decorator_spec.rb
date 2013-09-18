require 'spec_helper'

describe Spree::User do
  describe 'Association' do
    it { should have_and_belong_to_many(:roles).class_name('Spree::Role').with_foreign_key(:user_id) }
  end
end