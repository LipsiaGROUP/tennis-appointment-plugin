class StecmsAppointment::OperatorPolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_operators)
  end

  def new?
    user.can(:create_operators)
  end

  def create?
    new?
  end

  def edit?
    user.can(:manage_operators)
  end

  def update?
    edit?
  end

  def show?
    index?
  end

  def destroy?
    user.can(:destroy_operators)
  end

end