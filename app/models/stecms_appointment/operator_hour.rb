module StecmsAppointment
  class OperatorHour < ActiveRecord::Base
  	belongs_to :operator, class_name: 'StecmsAppointment::Operator', foreign_key: :stecms_appointment_operator_id
  	scope :active, -> { where('h_start <> ?', '--') }

  	attr_accessor :is_active
  end
end
