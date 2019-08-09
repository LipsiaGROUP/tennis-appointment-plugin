module StecmsAppointment
  module ClosedDatesHelper
  	def fixnum_to_date(fixnum)
	    Time.at(fixnum)
	  end

	  def date_range(salon_closed)
	    start_date = fixnum_to_date(salon_closed.start).strftime('%d-%m-%Y')
	    end_date = fixnum_to_date(salon_closed.end).strftime('%d-%m-%Y')

	    link_to(StecmsAppointment::Engine.routes.url_helpers.edit_closed_date_path(salon_closed), class: 'name event-link', remote: true) do
	      "Dal #{start_date} al #{end_date}"
	    end
	  end

	  def remaining_day(start_date, end_date)
	    remaining_day = ((Time.at(start_date) - Time.at(end_date)) / 86400).ceil

	    if remaining_day > 1
	      "#{remaining_day} giorni"
	    else
	      "#{remaining_day} giorno"
	    end
	  end
  end
end