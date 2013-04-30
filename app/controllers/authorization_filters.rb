module AuthorizationFilters
  def only_admins
    if not (current_user and current_user.admin?)
      redirect_to :root
    end
  end
end
