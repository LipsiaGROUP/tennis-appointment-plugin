class StecmsAppointment::ClosedDatePolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_closed_dates)
  end

  def new?
    user.can(:create_closed_dates)
  end

  def create?
    new?
  end

  def edit?
    user.can(:manage_closed_dates)
  end

  def update?
    edit?
  end

  def show?
    index?
  end

  def destroy?
    user.can(:destroy_closed_dates)
  end

end