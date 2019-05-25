module ApplicationHelper
  def flash_key_to_class(flash_key)
    associations = {
      notice: "success",
      info: "info",
      warning: "warning",
      error: "danger",
      alert: "danger"
    }
    associations[flash_key.to_sym]
  end
end
