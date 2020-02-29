class StecmsAppointment::CustomerPolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_customers)
  end

  def show?
    user.can(:see_customers)
  end

  def create?
    user.can(:see_customers)
  end

  def new?
    user.can(:see_customers)
  end

  def edit?
    user.can(:see_customers)
  end

  def update?
    user.can(:see_customers)
  end

  def destroy?
    user.can(:see_customers)
  end

  def search?
    user.can(:see_customers)
  end


end
