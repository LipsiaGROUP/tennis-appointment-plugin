class StecmsAppointment::ServiceCategoryPolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_service_categorys)
  end

  def new?
    user.can(:create_service_categorys)
  end

  def create?
    new?
  end

  def edit?
    user.can(:manage_service_categorys)
  end

  def update?
    edit?
  end

  def show?
    index?
  end

  def destroy?
    user.can(:destroy_service_categorys)
  end

end