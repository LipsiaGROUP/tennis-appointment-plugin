class CreateStecmsAppointmentSettings < ActiveRecord::Migration
  def change
    create_table :stecms_appointment_settings do |t|
      t.string :paypal_email
      t.string :paypal_clientid
      t.string :calendar_blocktime_colore, default: '#00BCDF'
      t.string :calendar_specialcategory_colore, default: '#EE1D7B'
      t.string :calendar_treatment_colore, default: '#AEB5BB'
      t.string :accepted_payment_options
      t.string :time_slots_granularity

      t.timestamps null: false
    end

    add_reference :stecms_appointment_business_hours, :stecms_appointment_settings

    setting = ::StecmsAppointment::Setting.create

    arr = []
    (0..6).each do |i|
      arr << setting.business_hours.new(day: i)
    end

    arr.map(&:save)
  end
end
