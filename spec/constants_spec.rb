require "spec_helper"

describe "CONSTANTS" do 
  describe 'PARAM_ATTRIBUTE' do
    context 'when it not has a key' do
      it 'should return :id' do
        PARAM_ATTRIBUTE['unknown'].should eq(:id)
      end
    end

    context 'when it key products' do
      it { PARAM_ATTRIBUTE['products'].should eq(:permalink) }
      it { PARAM_ATTRIBUTE['orders'].should eq(:number) }
      it { PARAM_ATTRIBUTE['shipments'].should eq(:number) }
    end
  end

  describe 'NEW_ACTIONS' do
    it 'should eq [:new, :create]' do
      NEW_ACTIONS.should eq([:new, :create])
    end
  end
end
