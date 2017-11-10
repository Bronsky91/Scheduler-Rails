# I suggest placing mixed in modules in module folder and removing "helper" from
# "SessionHelper" from name as "helper" means something in the Rails ecosystem.
module SessionUtils
  def log_in(user)
    session[:user_id] = user.id
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def logged_in?
    # !current_user.nil?
    # Want to avoid negatives if possible. Easier to read control flow
    current_user.present?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
