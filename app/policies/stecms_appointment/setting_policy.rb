class StecmsAppointment::SettingPolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_settings)
  end

  def edit?
    user.can(:manage_settings)
  end

  def update?
    edit?
  end

end