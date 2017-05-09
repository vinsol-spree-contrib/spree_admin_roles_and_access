module Spree
  module Admin
    class PermissionSetsController < ResourceController
      before_action :load_permissions, only: [:edit, :new, :create, :update]

      def index
        @search = Spree::PermissionSet.ransack(params[:q])
        @permission_sets = @search.result(distinct: true)
      end

      private def permitted_resource_params
        params.require(:permission_set).permit(:name, :description, :display_permission, permission_ids: [])
      end

      private def load_permissions
        @permissions = Spree::Permission.visible.all
      end
    end
  end
end
