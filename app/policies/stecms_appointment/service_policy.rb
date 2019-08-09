class StecmsAppointment::ServicePolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_services)
  end

  def new?
    user.can(:create_services)
  end

  def create?
    new?
  end

  def edit?
    user.can(:manage_services)
  end

  def update?
    edit?
  end

  def show?
    index?
  end

  def destroy?
    user.can(:destroy_services)
  end

end