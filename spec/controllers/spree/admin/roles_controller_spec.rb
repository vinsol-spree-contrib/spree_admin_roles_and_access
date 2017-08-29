require 'spec_helper'

RSpec.describe Spree::Admin::RolesController, type: :controller do
  let(:role) { mock_model(Spree::Role) }
  let(:roles) { [role] }
  let(:empty_roles) { [] }
  let(:user) { mock_model(Spree::User, email: 'userkonga.com', password: "password", password_confirmation: "password", roles: roles) }
  let(:permission) { mock_model(Spree::Permission) }
  let(:permission_set) { mock_model(Spree::PermissionSet) }
  let(:permissions) { [permission] }
  let(:permission_sets) { [permission_set] }
  let(:ability) { Spree::Ability.new(user) }

  before(:each) do
    allow(roles).to receive(:include_permissions).and_return(true)

    allow(controller).to receive(:spree_current_user).and_return(user)
    allow(user).to receive(:generate_spree_api_key!).and_return(true)
    allow(roles).to receive(:includes).and_return(roles)
    allow(role).to receive(:permissions).and_return([])

    ability.can :manage, :all
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(controller).to receive(:fetch_cart).and_return(true)
    allow(controller).to receive(:load_resource_instance).and_return(role)
    allow(controller).to receive(:fix_spree_user_var).and_return(true)
  end

  describe 'Index' do
    before(:each) do
      allow(Spree::Role).to receive(:page).and_return(roles)
    end

    def send_request
      spree_get :index
    end

    it 'should recieve page on Spree::Role' do
      expect(Spree::Role).to receive(:page).and_return(roles)
      send_request
    end

    it 'should render index page' do
      send_request
      expect(request).to render_template 'spree/admin/roles/index'
    end
  end

  describe 'edit' do
    def send_request
      spree_get :edit, id: role.id
    end

    before(:each) do
      allow(Spree::PermissionSet).to receive(:order).and_return(permission_sets)
      allow(role).to receive(:editable?).and_return(false)
    end

    describe 'load_permission_sets' do
      it 'should receive load_permissions and return true' do
        expect(controller).to receive(:load_permission_sets).and_return(true)
        send_request
      end

      it 'should receive visible on Spree::Permission' do
        expect(Spree::PermissionSet).to receive(:order).and_return(permission_sets)
        send_request
      end
    end

    describe 'restrict_unless_editable' do
      it 'should receive restrict_unless_editable and return true' do
        expect(controller).to receive(:restrict_unless_editable).and_return(true)
        send_request
      end

      context 'when role is not editable' do
        it 'should receive editable? on roles and return false' do
          expect(role).to receive(:editable?).and_return(false)
          send_request
        end

        it 'should redirect to admin_roles_path' do
          send_request
          expect(response).to redirect_to admin_roles_path
        end
      end

      context 'when role is not editable' do
        before(:each) do
          allow(role).to receive(:editable?).and_return(true)
        end

        it 'should redirect to admin_roles_path' do
          send_request
          expect(response).to render_template 'spree/admin/roles/edit'
        end
      end
    end
  end

  describe '#authorize_admin' do
    def send_request(params = {})
      spree_get :index, params
    end

    it 'should_receive model_class and return Spree::Role' do
      expect(controller).to receive(:model_class).exactly(4).and_return(Spree::Role)
      send_request
    end

    describe 'new_action?' do
      it 'should receive include? on NEW_ACTIONS' do
        expect(NEW_ACTIONS).to receive(:include?).with(:index).and_return(true)
        send_request
      end
    end

    shared_examples_for 'without_params_id' do
      it 'should not receive where on Spree::Role with id: params[:id]' do
        expect(Spree::Role).to_not receive(:where).with(id: role.id.to_s)
      end
    end

    shared_examples_for 'not_match_model_class' do
      it 'should not receive authorize! with :admin, Spree::Role' do
        expect(controller).to_not receive(:authorize!).with(:admin, Spree::Role)
      end

      it 'should not receive authorize_with_attributes! with :index, Spree::Role' do
        expect(controller).to_not receive(:authorize_with_attributes!).with(:index, Spree::Role, nil)
      end

      it 'should not receive authorize! with :index, Spree::Role' do
        expect(controller).to_not receive(:authorize!).with(:index, Spree::Role)
      end
    end

    context 'when there is model_class' do
      before(:each) do
        allow(Spree::Role).to receive(:where).and_return(roles)
        allow(roles).to receive(:joins).and_return(roles)
        allow(controller).to receive(:authorize!).and_return(true)
      end

      context 'when there is params[:id]' do
        after(:each) do
          send_request({id: role.id})
        end

        it 'should receive where on Spree::Role with id: params[:id]' do
          expect(Spree::Role).to receive(:where).with(id: role.id.to_s).and_return(roles)
        end

        it 'should receive authorize! with :admin, role' do
          expect(controller).to receive(:authorize!).with(:admin, role).and_return(true)
        end

        it 'should receive authorize_with_attributes! with :index, role' do
          expect(controller).to receive(:authorize_with_attributes!).with(:index, role, nil).and_return(true)
        end

        it 'should receive authorize! with :index, role' do
          expect(controller).to receive(:authorize!).with(:index, role).and_return(true)
        end

      end

      context 'when there is no params[:id]' do
        context 'when new_action? returns true' do
          before(:each) do
            allow(controller).to receive(:new_action?).and_return(true)
            allow(Spree::Role).to receive(:new).and_return(role)
          end

          after(:each) do
            send_request
          end

          it_should_behave_like 'without_params_id'

          it 'should receive authorize! with :admin, role' do
            expect(controller).to receive(:authorize!).with(:admin, role).and_return(true)
          end

          it 'should receive authorize! with :index, role' do
            expect(controller).to receive(:authorize_with_attributes!).with(:index, role, nil).and_return(true)
          end

          it 'should receive authorize! with :index, role' do
            expect(controller).to receive(:authorize!).with(:index, role).and_return(true)
          end
        end

        context 'when new_action? return false' do
          before(:each) do
            allow(controller).to receive(:new_action?).and_return(false)
            allow(Spree::Role).to receive(:new).and_return(role)
          end

          after(:each) do
            send_request
          end

          it_should_behave_like 'without_params_id'

          it 'should not receive authorize! with :admin, role' do
            expect(controller).to_not receive(:authorize!).with(:admin, role)
          end

          it 'should not receive authorize! with :index, role' do
            expect(controller).to_not receive(:authorize_with_attributes!).with(:index, role, nil)
          end

          it 'should not receive authorize! with :index, role' do
            expect(controller).to_not receive(:authorize!).with(:index, role)
          end

          it 'should receive authorize! with :admin, Spree::Role' do
            expect(controller).to receive(:authorize!).with(:admin, Spree::Role)
          end

          it 'should receive authorize! with :index, Spree::Role' do
            expect(controller).to receive(:authorize_with_attributes!).with(:index, Spree::Role, nil).and_return(true)
          end

          it 'should receive authorize! with :index, Spree::Role' do
            expect(controller).to receive(:authorize!).with(:index, Spree::Role).and_return(true)
          end
        end

        context 'when there are attributes' do
          it 'should receive authorize! with :admin, Spree::Role' do
            expect(controller).to receive(:authorize!).with(:admin, Spree::Role).and_return(true)
            send_request(role: {name: 'name'})
          end

          it 'should receive authorize! with :index, Spree::Role' do
            expect(controller).to receive(:authorize!).with(:index, Spree::Role, "name").and_return(true)
            send_request(role: {name: 'name'})
          end

          it 'should receive authorize_with_attributes! with :index, Spree::Role' do
            expect(controller).to receive(:authorize_with_attributes!).with(:index, Spree::Role, ActionController::Parameters.new({"name" => "name"})).and_return(true)
            send_request(role: {name: 'name'})
          end
        end

        context 'when there is a param with same name as controller_name.singularize but its not a hash' do
          it 'should receive authorize! with :admin, Spree::Role' do
            expect(controller).to receive(:authorize!).with(:admin, Spree::Role).and_return(true)
            send_request(role: 'name')
          end

          it 'should receive authorize_with_attributes! with :index, Spree::Role, name' do
            expect(controller).to receive(:authorize_with_attributes!).with(:index, Spree::Role, "name").and_return(true)
            send_request(role: "name")
          end

          it 'should receive authorize! with :index, Spree::Role' do
            expect(controller).to receive(:authorize!).with(:index, Spree::Role).and_return(true)
            send_request(role: 'name')
          end
        end
      end

      context 'when it is not a model_class' do
        before(:each) do
          allow(controller).to receive(:authorize!).and_return(true)
          allow(controller).to receive(:collection).and_return(roles)
          allow(controller).to receive(:model_class).and_return('spree/admin/overview')
        end

        it 'should receive authorize! with :admin, Spree::Role' do
          expect(controller).to receive(:authorize!).with(:admin, 'spree/admin/overview').and_return(true)
          send_request
        end

        it 'should receive authorize! with :index, Spree::Role' do
          expect(controller).to receive(:authorize!).with(:index, 'spree/admin/overview').and_return(true)
          send_request
        end

        it 'should receive authorize! with :index, Spree::Role' do
          expect(controller).to receive(:authorize_with_attributes!).with(:index, 'spree/admin/overview', nil).and_return(true)
          send_request
        end
      end
    end
  end

  describe 'permitted_resource_params' do
    let(:controller) { Spree::Admin::RolesController.new }

    before(:each) do
      @params = double('params')
      @parameters = {name: 'any-name'}
      allow(controller).to receive(:params).and_return(@params)
      allow(@params).to receive(:require).and_return(@parameters)
      allow(@parameters).to receive(:permit).and_return(@parameters)
    end

    describe 'should_receive' do
      after(:each) do
        controller.send(:permitted_resource_params)
      end

      it { expect(controller).to receive(:params).and_return(@params) }
      it { expect(@params).to receive(:require).with(:role).and_return(@parameters) }
      it { expect(@parameters).to receive(:permit).with(:name, :admin_accessible, :is_default, permission_set_ids: []).and_return(@parameters) }
    end
  end
end
