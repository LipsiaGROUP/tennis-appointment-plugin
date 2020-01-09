module StecmsAppointment
  class Operator < ActiveRecord::Base

  	scope :active, -> { where.not(status: 'cancelled') }
  	scope :active_working, -> { active.where(operator_active: 1) }
  	has_many :operator_hours, class_name: 'StecmsAppointment::OperatorHour', foreign_key: :stecms_appointment_operator_id, dependent: :destroy
 		has_many :bookings, foreign_key: 'stecms_appointment_operator_id', class_name: 'StecmsAppointment::Booking'
 		has_and_belongs_to_many :services, class_name: 'StecmsAppointment::Service',
    foreign_key: 'stecms_appointment_operator_id', association_foreign_key: 'stecms_appointment_service_id', allow_destroy: true

    scope :with_json_attributes, -> {
	    select('stecms_appointment_operators.id, gender, stecms_appointment_operators.status, mobile, email, created_at,
	      updated_at, operator_name, operator_active')
	  }

  	accepts_nested_attributes_for :operator_hours, reject_if: proc { |attributes| attributes['is_active'].to_i.zero? }, allow_destroy: true

  	class << self

		  def only_id_and_name
		    select(:id, :operator_name)
		  end

		  def get_id_and_name_hashes(salon_id)
		    only_id_and_name.map do |operator|
		      { id: operator.id, name: operator.operator_name }
		    end
		  end

		  # Returns operators id and name based on specific operator id and salon id - with hash format
		  #
		  def get_id_and_name_by_operator_hashes(operator_id)
		    where(operator_id: operator_id).map do |operator|
		      { id: operator.id, name: operator.operator_name }
		    end
		  end

		  # Returns operators available and unavailable operators based on specific salon id and specific date range
		  #
		  def get_available_and_unavailable_op(salon_id, start_time, end_time, duration)
		    bookings = ::StecmsAppointment::Booking.select("COUNT(*) AS booking_count, bookings.operator_id")
		      .where("((start_time <= :start AND end_time > :start) OR (start_time < :end AND end_time >= :end)) AND
		        stecms_appointment_bookings.status NOT IN('cancelled', 'user_cancelled')",
		        { start: start_time.to_i, end: end_time.to_i})
		      .group('stecms_appointment_bookings.stecms_appointment_operator_id')

		    operators = ::StecmsAppointment::Operator.active.with_json_attributes
		      .select("stecms_appointment_bookings.booking_count")
		      .joins("LEFT JOIN (#{bookings.to_sql}) AS bookings ON stecms_appointment_bookings.stecms_appointment_operator_id = stecms_appointment_operators.id")

		    operators_groups = operators.group_by do |operator|
		      operator.booking_count.present? ? :unavailable_employees : :employees
		    end

		    operators_groups[:employees] = operators_groups[:employees].map { |operator| operator.format_to_hash } rescue []
		    operators_groups[:unavailable_employees] = operators_groups[:unavailable_employees].map { |operator| operator.format_to_hash } rescue []

		    operators_groups.merge({ closing: false, duration: duration })
		  end

  		def get_hours_available(treatment, params)
  			setting = ::StecmsAppointment::Setting.last
		    when_param = params[:when]
		    duration_param = params[:duration]
		    operator_active_working = treatment.operators.active_working
		    salon = treatment.salon
		    rounding_time = setting.rounding
		    operator = operator_active_working.first
		    hours = []

		    if salon.booking_next_fifteen
		      allow_booking = true
		    else
		      allow_booking = Setting.allow_for_booking?(when_param, treatment)
		    end

		    if allow_booking
		      operator_id = params[:operator_id]
		      if operator_id.present?
		        operator = ::StecmsAppointment::Operator.find(operator_id)
		      else
		        operator_active_working_count = operator_active_working.count

		        unless operator_active_working_count.zero?
		          loop_index = 0
		          while operator_id == "" do
		            offset = rand(operator_active_working_count)
		            operator = operator_active_working.offset(offset).first
		            hours = operator.get_available_hours_for_treatment(duration_param, when_param, rounding_time)
		            operator_id = operator.id if hours.present?

		            loop_index = loop_index + 1
		            if loop_index.eql? operator_active_working_count
		              operator = operator_active_working.offset(offset).first
		              operator_id = operator.id
		            end
		          end
		        end

		      end

		      if operator and hours.blank?
		        hours = operator.get_available_hours_for_treatment(duration_param, when_param, rounding_time)
		      end
		    end

		    {operator: operator, hours: hours}
		  end

  		def time_step(stime, etime, step)
		    times = [stime.to_time]

		    while (times.last + eval("#{step}.second")) < etime.to_time
		      times << (times.last + eval("#{step}.second"))
		    end

		    times.map {|time| time.to_formatted_s(:time)}
		  end

  		def get_available_operators_for_treatment(params, when_param)
		    treatment = ::StecmsAppointment::Service.find(params[:treatment_id])
		    rounding_time = ::StecmsAppointment::Setting.last.try(:rounding)
		    duration_param = params[:duration]
		    operators_with_hours = []

		    # allow_booking = Salon.allow_for_booking?(when_param, treatment)
		    allow_booking = true

		    if allow_booking
		      operators = treatment.operators.active_working

		      if treatment.is_composed
		        composed_treatments = treatment.composed_treatments
		        first_composed_treatment = composed_treatments.first
		        first_treatment = first_composed_treatment.children_treatment rescue nil
		        second_treatment = composed_treatments.last.children_treatment rescue nil

		        if first_treatment.present?
		          first_treatment_duration = first_treatment.duration
		          second_treatment_duration = (second_treatment.duration rescue nil) || 60
		          next_time_ready_insecond = (first_composed_treatment.pause_time_minutes * 60) + first_treatment_duration

		          operators.each do |operator|
		            first_treatment_available_hours = operator.get_available_hours_for_treatment(first_treatment_duration, when_param, rounding_time)
		            second_treatment_available_hours = operator.get_available_hours_for_treatment(second_treatment_duration, when_param, rounding_time)

		            unless first_treatment_available_hours.empty?
		              if operators_with_hours.empty?
		                start_id = 1
		              else
		                start_id = operators_with_hours.last[:hours].last[:id] + 1
		              end

		              first_hours = first_treatment_available_hours.map.with_index { |hour, i| {id: i+start_id, hour: hour} }
		              second_treatment_available_hours = second_treatment_available_hours.map { |time| [time, (time.to_time + rounding_time.second).to_formatted_s(:time)] }
		              available_hours = []

		              first_hours.each do |hour_item|
		                time_entry = (hour_item[:hour].to_time + eval("#{next_time_ready_insecond}.second") )
		                selected_second_slot = []
		                second_treatment_available_hours.each do |second_time|
		                  if selected_second_slot.empty?
		                    if second_time[0].to_time >= time_entry.to_time
		                      if second_time[0].to_time.hour == time_entry.to_time.hour
		                        if second_time[0].to_time.min >= time_entry.to_time.min
		                          selected_second_slot << second_time
		                        end
		                      else
		                        selected_second_slot << second_time
		                      end
		                    end
		                  end
		                end

		                if selected_second_slot.present?
		                  available_hours << hour_item
		                end
		              end

		              if available_hours.present?
		                operators_with_hours << {operator_id: operator.id, operator_name: operator.operator_name, hours: available_hours}
		              end

		            end
		          end
		        else
		          operators.each do |operator|
		            available_hours = operator.get_available_hours_for_treatment(duration_param, when_param, rounding_time)
		            unless available_hours.empty?
		              if operators_with_hours.empty?
		                start_id = 1
		              else
		                start_id = operators_with_hours.last[:hours].last[:id] + 1
		              end
		              hours = available_hours.map.with_index { |hour, i| {id: i+start_id, hour: hour} }
		              operators_with_hours << {operator_id: operator.operator_id, operator_name: operator.operator_name, hours: hours}
		            end
		          end
		        end

		      else
		        operators.each do |operator|
		          available_hours = operator.get_available_hours_for_treatment(duration_param, when_param, rounding_time)
		          unless available_hours.empty?
		            if operators_with_hours.empty?
		              start_id = 1
		            else
		              start_id = operators_with_hours.last[:hours].last[:id] + 1
		            end
		            hours = available_hours.map.with_index { |hour, i| {id: i+start_id, hour: hour} }
		            operators_with_hours << {operator_id: operator.id, operator_name: operator.operator_name, hours: hours}
		          end
		        end
		      end
		    end
		    operators_with_hours
		  end

  		def get_operators_schedules_hashes(in_date = Date.today.to_time.to_i)
			  StecmsAppointment::Operator.all.map do |operator|
			    {
			      id: operator.id, name: operator.operator_name,
			      schedule: get_operator_schedules(in_date, operator),
			      services: operator.services.pluck(:id).map(&:to_s)
			    }
			  end
			end

			def get_hash
		    [{
		      id: nil,
		      name: nil,
		      provider_id: nil,
		      phone: nil,
		      address: nil,
		      city: nil,
		      created_at: '2015-04-24T09:00:00.000+02:00',
		      updated_at: '2015-04-24T09:00:00.000+02:00',
		      latitude: nil,
		      longitude: nil,
		      deleted_at: nil
		    }]
		  end

			def get_operators_infos_hashes
		    StecmsAppointment::Operator.active.select('status, created_at, updated_at,
		      operator_name as full_name, gender').map do |operator|
		      {
		        id: operator.id,
		        provider_id: nil,
		        gender: operator.gender,
		        status: "",
		        mobile_number: "",
		        email: "",
		        created_at: operator.created_at,
		        updated_at: operator.updated_at,
		        full_name: operator.full_name,
		        pricing_level_id: "",
		        deleted_at: nil,
		        role: "",
		        provides_services: true,
		        first_name: operator.full_name,
		        last_name: ""
		      }
		    end
		  end

		  def get_operator_schedules(in_date, operator)
		  	if StecmsAppointment::ClosedDate.closed_date_exist?(in_date)
		      []
		    else
		      salon_special_open = get_special_open(in_date)
		      schedule_data = operator.operator_hours.active.map { |schedule|
		        schedule_hash = {
		          date: Date.today.strftime('%Y%m%d'),
		          day: Date::DAYNAMES[schedule.day],
		          start_time: Time.parse(schedule.h_start).strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
		          end_time: Time.parse(schedule.h_end).strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
		          location_id: schedule.id
		        }

		        unless schedule.h_start2.eql?('--') || schedule.h_end2.eql?('--')
		          schedule_hash[:start_time2] = Time.parse(schedule.h_start2).strftime("%Y-%m-%dT%H:%M:%S.%3NZ")
		          schedule_hash[:end_time2] = Time.parse(schedule.h_end2).strftime("%Y-%m-%dT%H:%M:%S.%3NZ")
		        end
		        schedule_hash
		      }
		      if salon_special_open[:status]
		        new_schedule_data = salon_special_open[:new_schedule]
		        day_list = schedule_data.map { |item| item[:day] }
		        if day_list.include?(new_schedule_data[:day])
		          schedule_data = schedule_data.each do |item|
		            if item[:day] == new_schedule_data[:day]
		              item[:start_time] = new_schedule_data[:start_time]
		              item[:end_time] = new_schedule_data[:end_time]
		            end
		          end
		        else
		          schedule_data << new_schedule_data
		        end
		      end

		      schedule_data
		    end
		  end

		  def get_special_open(selected_date)
		    custom_open = StecmsAppointment::CustomOpen.where("(:selected_date between start_date AND end_date)", {selected_date: selected_date}).first
		    result = {status: false, new_schedule: nil}
		    if custom_open
		      schedule_hash = {
		        date: Date.today.strftime('%Y%m%d'),
		        day: Date::DAYNAMES[Time.at(selected_date).wday],
		        start_time: Time.parse(custom_open.time_open).strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
		        end_time: Time.parse(custom_open.time_closed).strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
		        location_id: id
		      }
		      result[:status] = true
		      result[:new_schedule] = schedule_hash
		    end
		    puts result

		    result
		  end

		  def get_id_and_name_hashes
		    select(:id, :operator_name).map do |operator|
		      { id: operator.id, name: operator.operator_name }
		    end
		  end

		  def get_id_and_name_by_operator_hashes(operator_id)
		    where(id: operator_id).map do |operator|
		      { id: operator.id, name: operator.operator_name }
		    end
		  end

  	end

  	## end self

  	def format_to_hash
	    {
	      id: self.id,
	      provider_id: nil,
	      gender: 'male',
	      status: self.status,
	      mobile_number: self.mobile,
	      email: self.email,
	      created_at: self.created_at,
	      updated_at: self.updated_at,
	      full_name: self.operator_name,
	      role: nil,
	      provides_services: self.operator_active
	    }
	  end

  	def get_overlap_time(time_array, end_time, end_time_2, start_time_2, date, second)

	    today_overlap_hours = []
	    current_time = Time.now
	    e_time = (end_time_2.present? ? end_time_2 : end_time).split(":")
	    close_time = current_time.change(hour: e_time[0], min: e_time[1])

	    if start_time_2.present? && end_time.present?
	      end_time_splitted = end_time.split(":")
	      break_time = current_time.change(hour: end_time_splitted[0], min: end_time_splitted[1])
	      after_break_time = current_time.change(hour: start_time_2.split(":")[0], min: start_time_2.split(":")[1])
	    end

	    if date == current_time.strftime("%d/%m/%Y")
	      time_array.each do |time|
	        time_splitted = time.split(":")
	        schedule_time = current_time.change(hour: time_splitted[0], min: time_splitted[1])
	        if schedule_time > current_time
	          today_overlap_hours << time
	        end
	      end
	    end

	    time_array.each do |time|
	      time_splitted = time.split(":")
	      schedule_time = current_time.change(hour: time_splitted[0], min: time_splitted[1]) + second.to_i
	      if (schedule_time < close_time) || (break_time.present? && schedule_time > break_time && schedule_time < after_break_time)
	        today_overlap_hours << time
	      end
	    end
	    today_overlap_hours
	  end

  	def get_booking_time(bookings, time_array, second, date)
	    bookings_time = []
	    time_array.each do |ta|
	      op_time = Time.parse("#{date} #{ta}").to_i
	      bookings.each do |booking|
	        if (op_time..op_time+second).overlaps?(booking.start_time+1..booking.end_time-1)
	          bookings_time << ta
	        end
	      end
	    end

	    bookings_time
	  end

  	def get_available_hours_for_treatment(second, date = Date.today.strftime("%d/%m/%Y"), rounding_time = 600)
	    setting = ::StecmsAppointment::Setting.last
	    date_treatment = date.to_date
	    wday = date_treatment.wday
	    today = Time.now
	    special_open = ::StecmsAppointment::CustomOpen.get_special_open(date.to_time.to_i)

	    if special_open[:status]
	      new_schedule = special_open[:new_schedule]
	      start_time_special = new_schedule[:start_time].to_datetime.strftime("%H:%M")
	      end_time_special = new_schedule[:end_time].to_datetime.strftime("%H:%M")
	      salon_hour_db = ::StecmsAppointment::BusinessHour.new(h_start: start_time_special, h_end: end_time_special, h_start2: "00:00", h_end2: "00:00")
	      hour_db = ::StecmsAppointment::OperatorHour.new(h_start: start_time_special, h_end: end_time_special, h_start2: "00:00", h_end2: "00:00")
	    else
	      hour_db = self.operator_hours.where(day: wday).first
	      salon_hour_db = ::StecmsAppointment::BusinessHour.where(day: wday).first
	    end

	    time_array = []

	    if hour_db && salon_hour_db
	      h_start = hour_db.h_start
	      h_end = hour_db.h_end
	      h_start2 = hour_db.h_start2
	      h_end2 = hour_db.h_end2
	      s_start = salon_hour_db.h_start
	      s_end = salon_hour_db.h_end
	      s_start2 = salon_hour_db.h_start2
	      s_end2 = salon_hour_db.h_end2

	      unless (h_start.to_i.zero? && h_end.to_i.zero? && h_start2.to_i.zero? && h_end2.to_i.zero?)
	        start_time = h_start.to_i > s_start.to_i ? h_start : s_start
	        end_time = h_end.to_i < s_end.to_i ? h_end : s_end

	        hour_end = h_end2.to_i.zero? ? h_end : h_end2
	        range_time = ["#{date}".to_time.to_i, "#{date} #{hour_end}".to_time.to_i]
	        bookings = self.bookings.select(:start_time, :duration, :end_time, :id, :stecms_appointment_service_id, :duration, :price).where("start_time BETWEEN ? AND ?", range_time[0], range_time[1]).where(is_composed_treatment: false)

	        time_array += ::StecmsAppointment::Operator.time_step(start_time, end_time, rounding_time.to_i)

	        if s_start2.to_i.zero? && !h_start2.to_i.zero?
	          start_time_2 = h_start2
	            end_time_2 = h_end2.to_i < s_end.to_i ? h_end2 : s_end
	        elsif !s_start2.to_i.zero? && h_start2.to_i.zero?
	          start_time_2 = s_start2
	            end_time_2 = h_end.to_i < s_end2.to_i ? h_end : s_end2
	        elsif !(s_start2.to_i.zero? && h_start2.to_i.zero?)
	          start_time_2 = h_start2.to_i > s_start2.to_i ? h_start2 : s_start2
	            end_time_2 = h_end2.to_i < s_end2.to_i ? h_end2 : s_end2
	        end

	        time_array += ::StecmsAppointment::Operator.time_step(start_time_2, end_time_2, rounding_time.to_i) if start_time_2.present? && end_time_2.present?

	        bookings_time = get_booking_time(bookings, time_array, second.to_f, date)
	        today_overlap_hours = get_overlap_time(time_array, end_time, end_time_2, start_time_2, date, second)

	        time_array.delete("00:00")
	        time_array = (time_array - bookings_time) - today_overlap_hours
	      end
	    end

	    if setting.booking_next_fifteen
	      if date_treatment.eql?(today.to_date)
	        time_array.delete_if do |hour|
	          hour_and_minutes = hour.split(":")
	          array_time = Time.new(today.year, today.mon, today.day, hour_and_minutes[0].to_i, hour_and_minutes[1].to_i)
	          (array_time - today) < 900
	        end
	      end
	    else
	      if ((today.hour >= 16) and date_treatment.eql?(today.tomorrow.to_date)) or ((today.hour < 11) and date_treatment.eql?(today.to_date))
	        time_array.delete_if do |hour|
	          hour_and_minutes = hour.split(":")
	          (hour_and_minutes[0].to_i <= 11 and hour_and_minutes[1].to_i < 30) or ( hour_and_minutes[0].to_i < 11 and hour_and_minutes[1].to_i < 60 )
	        end
	      end

	      if date_treatment.eql?(today.to_date)
	        max_hour = today.hour + 5
	        time_array.delete_if do |hour|
	          hour_and_minutes = hour.split(":")
	          hour_and_minutes[0].to_i < max_hour
	        end
	      end
	    end

	    time_array
	  end
  end
end
