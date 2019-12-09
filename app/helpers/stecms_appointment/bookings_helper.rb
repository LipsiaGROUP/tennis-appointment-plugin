module StecmsAppointment
  module BookingsHelper

    def get_payment_options(treatment)
    payment_options = {
      in_salon: {
        id: 'paga-salone', text: 'Paga in salone'
      }
    }
    payment_options.merge!({electronic_card: {id: 'paga-subito', text: 'Paga con carta'}}) if treatment.price.to_i
    payment_options
  end

  	def location_data
  		StecmsAppointment::Operator.get_hash.to_json
  	end

    def fixnum_to_date(fixnum)
      Time.at(fixnum)
    end

  	def get_operators_schedules_hashes
  		StecmsAppointment::Operator.get_operators_schedules_hashes.to_json
  	end

  	def get_operators_infos_hashes
  		StecmsAppointment::Operator.get_operators_infos_hashes.to_json
  	end

    def mio_collection_time(date_selected, collection)
      new_item_collection = [date_selected.strftime('%H:%M') , date_selected.strftime('%H:%M:%S')]
      collection << new_item_collection
      collection.uniq { |item| item[1] }.sort_by { |item| Time.parse(item[1]) }
    end

    def times_by_interval(rounding)
      start_time = Time.now.beginning_of_day
      end_time = Time.now.end_of_day
      interval = rounding / 60
      options = []

      loop do
        start_time_label = start_time.strftime("%H:%M")
        options << [start_time_label, start_time_label + ':00']
        start_time += interval.minutes
        break if start_time > end_time
      end

      options
    end
  end
end
