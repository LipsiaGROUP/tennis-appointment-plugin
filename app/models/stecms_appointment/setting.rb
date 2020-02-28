module StecmsAppointment
  class Setting < ActiveRecord::Base
  	has_many :business_hours, foreign_key: :stecms_appointment_settings_id, dependent: :destroy
  	accepts_nested_attributes_for :business_hours#, reject_if: proc { |attributes| attributes['is_active'].to_i.zero? }, allow_destroy: true
  end
end
