class StecmsAppointment::CustomerPolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_customers)
  end

  def show?
    user.can(:see_customers)
  end


end
