class StecmsAppointmentPolicy < AdminPolicy
  
  protected
    def appointments_enabled?
      LipsiaWEB[:modules][:appointments]
    end
end