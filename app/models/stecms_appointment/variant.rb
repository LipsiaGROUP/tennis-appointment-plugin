module StecmsAppointment
  class Variant < ActiveRecord::Base
    scope :short_hair, -> { where('stecms_appointment_variants.title LIKE ?', '%corti%') }
    scope :long_hair, -> { where('stecms_appointment_variants.title LIKE ?', '%folti%') }
    scope :standard, -> { where('stecms_appointment_variants.title LIKE ?', '%standard%') }
  end
end
