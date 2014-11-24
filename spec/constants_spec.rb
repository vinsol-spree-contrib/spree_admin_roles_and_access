require "spec_helper"

RSpec.describe "CONSTANTS" do 
  describe 'PARAM_ATTRIBUTE' do
    context 'when it not has a key' do
      it 'should return :id' do
        expect(PARAM_ATTRIBUTE['unknown']).to eq(:id)
      end
    end

    context 'when it key products' do
      it { expect(PARAM_ATTRIBUTE['products']).to eq(:slug) }
      it { expect(PARAM_ATTRIBUTE['orders']).to eq(:number) }
      it { expect(PARAM_ATTRIBUTE['shipments']).to eq(:number) }
    end
  end

  describe 'NEW_ACTIONS' do
    it 'should eq [:new, :create]' do
      expect(NEW_ACTIONS).to eq([:new, :create])
    end
  end
end
