module StecmsAppointment
  class BusinessHour < ActiveRecord::Base
  	belongs_to :setting

	  attr_accessor :is_active

	  attribute :day, Type::Integer.new

	  class << self
	    # Returns salon available hours info
	    # Currently moved to salon
	    #
	    def get_schedule
	      hours = {}
	      result = select(:day, :h_start, :h_end, :h_start2, :h_end2).order(:day)
	      if result.present?
	        result.each do |schedule|
	          schedule.h_start2 = nil if schedule.h_start2 == "00:00"
	          schedule.h_end2 = nil if schedule.h_end2 == "00:00"
	          stamp_day = schedule.day# == 0 ? 7 : schedule.day
	          if schedule.h_start2 == nil
	            hours[stamp_day] = {h_start: schedule.h_start, h_end: schedule.h_end}
	          else
	            hours[stamp_day] = {h_start: schedule.h_start, h_end: schedule.h_end, h_start2: schedule.h_start2, h_end2: schedule.h_end2}
	          end
	        end
	      end
	      return hours
	    end

	    def salon_work_days
	    end

	  end
  end
end
