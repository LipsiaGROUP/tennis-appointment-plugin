module CalendarBooking

	def self.date_month_content(month, year)
		current_year = Date.today.year
    current_month = Date.today.month

    if month.zero? or year.zero?
      year = current_year
      month = current_month            
    end

    if(current_year != year) or (current_month != month)
      start_day = Date.new(year, month)
    else
      start_day = Date.today
    end
    
    months = []
    month_names = I18n.t("date.month_names")
    i = 1
    
    while i <= 12
      if month_names[month].nil?
        months << {month: month_names[month-12].capitalize, year: year + 1, month_id: (month- 12), id: i}
      else
        months << {month: month_names[month].capitalize, year: year, month_id: month, id: i}
      end
      i += 1
      month += 1
    end

    is_off_days = ::StecmsAppointment::BusinessHour.is_off.pluck(:day)

    days = (start_day..start_day.end_of_month).to_a
    day_list =[]
     days.each.with_index(1).each do  |day, index| 
      day_list << {id: index, 
        date: sprintf("%02d", day.day), 
        day: I18n.l(day, format: '%A'), 
        shortDay: I18n.l(day, format: '%a'),
        is_off: (is_off_days.include?(day.wday))
      } 
    end
    
    {months: months, days: day_list}
	end

end