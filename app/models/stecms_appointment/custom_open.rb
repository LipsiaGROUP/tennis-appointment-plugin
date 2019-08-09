module StecmsAppointment
  class CustomOpen < ActiveRecord::Base

  	def self.get_special_open(selected_date)
	    custom_open = where("(:selected_date between start_date AND end_date)", {selected_date: selected_date}).first
	    puts selected_date
	    result = {status: false, new_schedule: nil}
	    if custom_open
	      schedule_hash = {
	        date: Date.today.strftime('%Y%m%d'),
	        day: Date::DAYNAMES[Time.at(selected_date).wday],
	        start_time: Time.parse(custom_open.time_open).strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
	        end_time: Time.parse(custom_open.time_closed).strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
	        location_id: self.id
	      }
	      result[:status] = true
	      result[:new_schedule] = schedule_hash
	    end
	    puts result

	    result
	  end

  end
end
