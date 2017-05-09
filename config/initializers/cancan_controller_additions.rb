CanCan::ControllerAdditions.class_eval do
  # specs of #authorize_with_attributes! is written in authorize_admin in roles_controller_spec
  def authorize_with_attributes!(action, subject, attributes = [])
    attributes = attributes.keys if attributes.respond_to?(:keys)
    if attributes.is_a? Array
      attributes.each { |attribute| authorize!(action, subject, attribute) }
    else
      authorize!(action, subject)
    end
  end
end
