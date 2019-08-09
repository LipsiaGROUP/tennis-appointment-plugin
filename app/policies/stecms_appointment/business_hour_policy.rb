class StecmsAppointment::BusinessHourPolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_business_hours)
  end

  def update?
  	user.can(:manage_business_hours)
  end
end