require 'spec_helper'

describe Spree::Admin::RolesController do
  let(:role) { mock_model(Spree::Role) }
  let(:roles) { [role] }
  let(:empty_roles) { [] }
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
    controller.stub(:load_resource_instance).and_return(role)
    controller.stub(:fix_spree_user_var).and_return(true)
  end
  
  describe 'Index' do
    before(:each) do
      Spree::Role.stub(:page).and_return(roles)
    end

    def send_request
      get :index, :use_route => 'spree'
    end

    it 'should recieve page on Spree::Role' do
      Spree::Role.should_receive(:page).and_return(roles)
      send_request
    end

    it 'should render index page' do
      send_request
      request.should render_template 'spree/admin/roles/index'
    end
  end  

  describe 'edit' do
    def send_request
      get :edit, :id => role.id, :use_route => 'spree'
    end

    before(:each) do
      Spree::Permission.stub(:visible).and_return(permissions)
      permissions.stub(:all).and_return(permissions)
      role.stub(:editable?).and_return(false)
    end

    describe 'load_permissions' do
      it 'should receive load_permissions and return true' do
        controller.should_receive(:load_permissions).and_return(true)
        send_request
      end

      it 'should receive visible on Spree::Permission' do
        Spree::Permission.should_receive(:visible).and_return(permissions)
        send_request
      end

      it 'should receive all on permissions' do
        permissions.should_receive(:all).and_return(permissions)
        send_request
      end
    end

    describe 'restrict_unless_editable' do
      it 'should receive restrict_unless_editable and return true' do
        controller.should_receive(:restrict_unless_editable).and_return(true)
        send_request
      end

      context 'when role is not editable' do
        it 'should receive editable? on roles and return false' do
          role.should_receive(:editable?).and_return(false)
          send_request
        end

        it 'should redirect to admin_roles_path' do
          send_request
          response.should redirect_to admin_roles_path
        end
      end

      context 'when role is not editable' do
        before(:each) do
          role.stub(:editable?).and_return(true)
        end

        it 'should redirect to admin_roles_path' do
          send_request
          response.should render_template 'spree/admin/roles/edit'
        end
      end
    end
  end

  describe '#authorize_admin' do
    def send_request(params = {})
      get :index, params.merge(:use_route => 'spree')
    end

    it 'should_receive model_class and return Spree::Role' do
      controller.should_receive(:model_class).exactly(4).and_return(Spree::Role)
      send_request
    end

    describe 'new_action?' do
      it 'should receive include? on NEW_ACTIONS' do
        NEW_ACTIONS.should_receive(:include?).with(:index).and_return(true)
        send_request
      end
    end

    shared_examples_for 'without_params_id' do
      it 'should not receive where on Spree::Role with :id => params[:id]' do
        Spree::Role.should_not_receive(:where).with(:id => role.id.to_s)
      end
    end

    shared_examples_for 'not_match_model_class' do
      it 'should not receive authorize! with :admin, Spree::Role' do
        controller.should_not_receive(:authorize!).with(:admin, Spree::Role)
      end

      it 'should not receive authorize_with_attributes! with :index, Spree::Role' do
        controller.should_not_receive(:authorize_with_attributes!).with(:index, Spree::Role, nil)
      end

      it 'should not receive authorize! with :index, Spree::Role' do
        controller.should_not_receive(:authorize!).with(:index, Spree::Role)
      end
    end

    context 'when there is model_class' do
      before(:each) do
        Spree::Role.stub(:where).and_return(roles)
        roles.stub(:joins).and_return(roles)
        controller.stub(:authorize!).and_return(true)
      end

      context 'when there is params[:id]' do
        after(:each) do
          send_request({:id => role.id})
        end

        it 'should receive where on Spree::Role with :id => params[:id]' do
          Spree::Role.should_receive(:where).with(:id => role.id.to_s).and_return(roles)
        end

        it 'should receive authorize! with :admin, role' do
          controller.should_receive(:authorize!).with(:admin, role).and_return(true)
        end

        it 'should receive authorize_with_attributes! with :index, role' do
          controller.should_receive(:authorize_with_attributes!).with(:index, role, nil).and_return(true)
        end

        it 'should receive authorize! with :index, role' do
          controller.should_receive(:authorize!).with(:index, role).and_return(true)
        end

        it_should_behave_like 'not_match_model_class'
      end

      context 'when there is no params[:id]' do
        context 'when new_action? returns true' do
          before(:each) do
            controller.stub(:new_action?).and_return(true)
            Spree::Role.stub(:new).and_return(role)
          end

          after(:each) do
            send_request
          end

          it_should_behave_like 'without_params_id'
          it_should_behave_like 'not_match_model_class'

          it 'should receive authorize! with :admin, role' do
            controller.should_receive(:authorize!).with(:admin, role).and_return(true)
          end

          it 'should receive authorize! with :index, role' do
            controller.should_receive(:authorize_with_attributes!).with(:index, role, nil).and_return(true)
          end

          it 'should receive authorize! with :index, role' do
            controller.should_receive(:authorize!).with(:index, role).and_return(true)
          end   
        end
  
        context 'when new_action? return false' do
          before(:each) do
            controller.stub(:new_action?).and_return(false)
            Spree::Role.stub(:new).and_return(role)
          end

          after(:each) do
            send_request
          end

          it_should_behave_like 'without_params_id'

          it 'should not receive authorize! with :admin, role' do
            controller.should_not_receive(:authorize!).with(:admin, role)
          end

          it 'should not receive authorize! with :index, role' do
            controller.should_not_receive(:authorize_with_attributes!).with(:index, role, nil)
          end

          it 'should not receive authorize! with :index, role' do
            controller.should_not_receive(:authorize!).with(:index, role)
          end   

          it 'should receive authorize! with :admin, Spree::Role' do
            controller.should_receive(:authorize!).with(:admin, Spree::Role)
          end

          it 'should receive authorize! with :index, Spree::Role' do
            controller.should_receive(:authorize_with_attributes!).with(:index, Spree::Role, nil).and_return(true)
          end

          it 'should receive authorize! with :index, Spree::Role' do
            controller.should_receive(:authorize!).with(:index, Spree::Role).and_return(true)
          end
        end

        context 'when there are attributes' do
          it 'should receive authorize! with :admin, Spree::Role' do
            controller.should_receive(:authorize!).with(:admin, Spree::Role).and_return(true)
            send_request(:role => {:name => 'name'})
          end

          it 'should receive authorize! with :index, Spree::Role' do
            controller.should_receive(:authorize!).with(:index, Spree::Role, "name").and_return(true)
            send_request(:role => {:name => 'name'})
          end

          it 'should receive authorize_with_attributes! with :index, Spree::Role' do
            controller.should_receive(:authorize_with_attributes!).with(:index, Spree::Role, {"name" => "name"}).and_return(true)
            send_request(:role => {:name => 'name'})
          end
        end

        context 'when there is a param with same name as controller_name.singularize but its not a hash' do
          it 'should receive authorize! with :admin, Spree::Role' do
            controller.should_receive(:authorize!).with(:admin, Spree::Role).and_return(true)
            send_request(:role => 'name')
          end

          it 'should receive authorize_with_attributes! with :index, Spree::Role, name' do
            controller.should_receive(:authorize_with_attributes!).with(:index, Spree::Role, "name").and_return(true)
            send_request(:role => "name")
          end

          it 'should receive authorize! with :index, Spree::Role' do
            controller.should_receive(:authorize!).with(:index, Spree::Role).and_return(true)
            send_request(:role => 'name')
          end
        end
      end

      context 'when it is not a model_class' do
        before(:each) do
          controller.stub(:authorize!).and_return(true)
          controller.stub(:collection).and_return(roles)
          controller.stub(:model_class).and_return('spree/admin/overview')
        end

        it 'should receive authorize! with :admin, Spree::Role' do
          controller.should_receive(:authorize!).with(:admin, 'spree/admin/overview').and_return(true)
          send_request
        end

        it 'should receive authorize! with :index, Spree::Role' do
          controller.should_receive(:authorize!).with(:index, 'spree/admin/overview').and_return(true)
          send_request
        end

        it 'should receive authorize! with :index, Spree::Role' do
          controller.should_receive(:authorize_with_attributes!).with(:index, 'spree/admin/overview', nil).and_return(true)
          send_request
        end
      end
    end
  end

  describe 'permitted_resource_params' do
    let(:controller) { Spree::Admin::RolesController.new }

    before(:each) do
      @params = double('params')
      @parameters = {:name => 'any-name'}
      controller.stub(:params).and_return(@params)
      @params.stub(:require).and_return(@parameters)
      @parameters.stub(:permit).and_return(@parameters)
    end
    
    describe 'should_receive' do
      after(:each) do
        controller.send(:permitted_resource_params)
      end

      it { controller.should_receive(:params).and_return(@params) }
      it { @params.should_receive(:require).with(:role).and_return(@parameters) }
      it { @parameters.should_receive(:permit).with(:name, :permission_ids).and_return(@parameters) }
    end
  end
end