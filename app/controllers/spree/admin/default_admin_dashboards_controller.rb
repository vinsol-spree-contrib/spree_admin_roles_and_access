class Spree::Admin::DefaultAdminDashboardsController < Spree::Admin::BaseController
  skip_before_action :authorize_admin, only: :show
  before_action :authorize_user_has_admin_role, only: :show

  def show
  end

  private def authorize_user_has_admin_role
    user = try_spree_current_user
    raise CanCan::AccessDenied unless user.present?
    raise CanCan::AccessDenied unless user.roles.any? { |role| role.admin_accessible? }
  end
end
