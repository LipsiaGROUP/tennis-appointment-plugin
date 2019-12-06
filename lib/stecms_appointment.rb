require "stecms_appointment/engine"

module StecmsAppointment
  class ActionDispatch::Routing::Mapper
    def stecms_appointment
      instance_eval(File.read(StecmsAppointment::Engine.root.join("config/routes/stecms_appointment.rb")))
    end
  end
end
