class Setting 
	def self.allow_for_booking?(when_param, treatment)
    date_treatment = when_param.to_date
    date_treatment_int = when_param.to_time.to_i
    today = Time.now
    easter_sunday = Computus.calculate(today.year)
    easter_monday = easter_sunday + 1
    italy_festivity = ITALY_FESTIVITY + [easter_sunday, easter_monday]
    check_festivity = italy_festivity.detect {|date| (date.month == date_treatment.month) and (date.day == date_treatment.day) }

    if (["02", "03"].include? date_treatment.strftime("%d") and date_treatment.strftime("%m").eql?("06")) and (today > Time.new(2017, 06, 01, 13))
      false
    elsif check_festivity
      false
    elsif ::StecmsAppointment::ClosedDate.closed_date_exist?(date_treatment_int, treatment.salon_id)
      false
    elsif today.friday? && date_treatment.saturday?
      today.hour <= 13
    elsif date_treatment.eql?(today.to_date)
      if today.saturday?
        false
      else
        if today.hour == 11
          today.min <= 30
        elsif today.hour < 11
          true
        else
          false
        end
      end
    else
      true
    end
  end
end