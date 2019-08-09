module StecmsAppointment
  class Promotion < ActiveRecord::Base
    belongs_to :service, class_name: 'StecmsAppointment::Service', foreign_key: :stecms_appointment_service_id
    belongs_to :variant, class_name: 'StecmsAppointment::Variant', foreign_key: :stecms_appointment_variant_id

    scope :inactive, -> (current_active_days, des_variant) {
      joins('LEFT JOIN stecms_appointment_variants ON stecms_appointment_promotions.stecms_appointment_variant_id = stecms_appointment_variants.id')
      .where("stecms_appointment_promotions.day NOT IN (?) OR stecms_appointment_variants.title LIKE ?",
        current_active_days, "%#{des_variant}%")
    }

    attr_accessor :is_active, :short_price, :long_price, :discount_short_price, :discount_long_price
  end
end
