class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # renamed SessionsHelper to SessionsUtils and placed in app/modules directory
  include SessionUtils

  # removed UsersHelper as Rails automatically includes view Helpers
end
