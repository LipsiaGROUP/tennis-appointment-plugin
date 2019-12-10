class StecmsAppointment::BookingPolicy < StecmsAppointmentPolicy
  def index?
    user.can(:see_bookings)
  end

  def confirm_delete?
    destroy?
  end

  def drag_and_drop_busy_time?
    edit?
  end

  def new_busy_time?
    new?
  end

  def edit_busy_time?
    edit?
  end

  def create_busy_time?
    new?
  end

  def update_busy_time?
    edit?
  end

  def delete_busy_time?
    destroy?
  end

  def drag_and_drop?
    edit?
  end

  def update_status?
    edit?
  end

  def agenda?
    index?
  end

  def get_variants?
    true
  end

  def get_updates?
    index?
  end

  def calendar?
    index?
  end

  def new?
    user.can(:create_bookings)
  end

  def create?
    new?
  end

  def edit?
    user.can(:manage_bookings)
  end

  def update?
    edit?
  end

  def show?
    index?
  end

  def destroy?
    user.can(:destroy_bookings)
  end

end
