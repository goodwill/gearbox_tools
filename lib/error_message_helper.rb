module ErrorMessageHelper
  def show_error_messages(object)
    controller.send(:render_to_string, :partial=>'/common/error_messages', :object=>object) if object.errors.count > 0
  end
end