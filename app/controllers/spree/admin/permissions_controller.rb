module Spree
  module Admin
    class PermissionsController < ResourceController
      before_filter :restrict_unless_editable, :only => [:edit, :update]

      def index
        @permissions = Spree::Permission.page(params[:page])
      end

      private

        def permitted_resource_params
          params.require(:permission).permit(:title)
        end

        def restrict_unless_editable
          redirect_to admin_roles_path unless @permission.editable?
        end
    end
  end
end
