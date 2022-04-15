module SpreeAdminRolesAndAccess
  module Spree
    module Admin
      module BaseControllerDecorator
        def authorize_admin
          begin
            if params[:id]
              record = model_class.where(PARAM_ATTRIBUTE[controller_name] => params[:id]).first
            elsif new_action?
              record = model_class.new
            else
              record = model_class
            end
            raise if record.blank?
          rescue
            record = "#{params[:controller]}"
          end
          authorize! :admin, record
          authorize_with_attributes! params[:action].to_sym, record, params[controller_name.singularize]
        end

        private

        def unauthorized
          redirect_unauthorized_access
        end

        def new_action?
          NEW_ACTIONS.include?(params[:action].to_sym)
        end
      end
    end
  end
end

::Spree::Admin::BaseController.prepend SpreeAdminRolesAndAccess::Spree::Admin::BaseControllerDecorator
