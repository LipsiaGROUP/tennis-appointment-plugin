module StecmsAppointment
  class ComposedService < ActiveRecord::Base
  	belongs_to :main_treatment, foreign_key: :service_parent_id, class_name: 'StecmsAppointment::Service'
		belongs_to :children_treatment, foreign_key: :stecms_appointment_service_id, class_name: 'StecmsAppointment::Service'
  end
end