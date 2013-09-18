Spree::Admin::BaseController.class_eval do
  def authorize_admin
    begin
      if params[:id]
        record = model_class.where(PARAM_ATTRIBUTE[controller_name] => params[:id]).first
      elsif new_action?
        record = model_class.new
      else
        record = model_class
        raise if record.blank?  ## This is done because on some machines model_class returns nil instead of raising an exception.
      end
    rescue
      record = "#{params[:controller]}"
    end
    authorize! :admin, record
    authorize_with_attributes! params[:action].to_sym, record, params[controller_name.singularize]
  end

  private
    def new_action?
      NEW_ACTIONS.include?(params[:action].to_sym)
    end
end
