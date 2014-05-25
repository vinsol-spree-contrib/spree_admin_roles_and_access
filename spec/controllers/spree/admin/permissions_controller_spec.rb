require 'spec_helper'

describe Spree::Admin::PermissionsController do
  let(:role) { mock_model(Spree::Role) }
  let(:roles) { [role] }
  let(:user) { mock_model(Spree::User, :email => 'userkonga.com', :password => "password", :password_confirmation => "password", :roles => roles) }
  let(:permission) { mock_model(Spree::Permission) }
  let(:permissions) { [permission] }
  let(:ability) { Spree::Ability.new(user) }

  before(:each) do
    roles.stub(:include_permissions).and_return(true)

    controller.stub(:spree_current_user).and_return(user)
    user.stub(:generate_spree_api_key!).and_return(true)
    roles.stub(:includes).and_return(roles)
    role.stub(:ability).and_return(true)

    ability.can :manage, :all
    controller.stub(:current_ability).and_return(ability)
    controller.stub(:fetch_cart).and_return(true)
    controller.stub(:load_resource_instance).and_return(permission)
    controller.stub(:fix_spree_user_var).and_return(true)
  end

  describe '#index' do
    before(:each) do
      Spree::Permission.stub(:page).and_return(permissions)
    end

    def send_request
      get :index, :use_route => 'spree'
    end

    it 'should recieve page on Spree::Role' do
      Spree::Permission.should_receive(:page).and_return(permissions)
      send_request
    end

    it 'should render index page' do
      send_request
      request.should render_template 'spree/admin/permissions/index'
    end
  end

  describe 'permitted_resource_params' do
    let(:controller) { Spree::Admin::PermissionsController.new }

    before(:each) do
      @params = double('params')
      @parameters = {:title => 'any-title'}
      controller.stub(:params).and_return(@params)
      @params.stub(:require).and_return(@parameters)
      @parameters.stub(:permit).and_return(@parameters)
    end

    describe 'should_receive' do
      after(:each) do
        controller.send(:permitted_resource_params)
      end

      it { controller.should_receive(:params).and_return(@params) }
      it { @params.should_receive(:require).with(:permission).and_return(@parameters) }
      it { @parameters.should_receive(:permit).with(:title).and_return(@parameters) }
    end
  end
end
