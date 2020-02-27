module StecmsAppointment
  class ClosedDate < ActiveRecord::Base

  	def self.closed_date_exist?(date)
  		where("start <= :date AND end >= :date", {date: date}).present?
  	end

  	def number_of_day_label
	    start_date = Date.strptime(self.start.to_s, '%s') rescue Date.today
	    end_date = Date.strptime(self.end.to_s, '%s') rescue Date.today
	    num_of_days = (start_date..end_date).count
	    "#{num_of_days} #{ num_of_days.eql?(1) ? 'giorno' : 'giorni' }"
	  end

  end
end
