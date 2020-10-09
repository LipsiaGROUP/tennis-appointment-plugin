require 'ancestry'

module StecmsAppointment
	class Booking < ActiveRecord::Base
  	has_ancestry
  	belongs_to :service, class_name: 'StecmsAppointment::Service', foreign_key: 'stecms_appointment_service_id'
  	belongs_to :operator, class_name: 'StecmsAppointment::Operator', foreign_key: 'stecms_appointment_operator_id'
  	belongs_to :user, class_name: 'StecmsAppointment::Customer', foreign_key: 'stecms_appointment_customer_id'

  	before_save :set_title
    before_create :generate_code_order

  	scope :with_operator_id, -> (operator_id) { where(stecms_appointment_operator_id: operator_id) }
  	scope :new_bookings, -> (now_minus_interval, start_time, end_time) {
  		where('created_at >= ? AND start_time > ? AND start_time < ?', now_minus_interval, start_time, end_time)
  	}

  	scope :new_removed_bookings, -> (now_minus_interval, start_time, end_time) {
  		select(:id)
  		.where('updated_at >= ? AND start_time > ? AND start_time < ?', now_minus_interval, start_time, end_time)
  		.where(status: ['cancelled', 'user_cancelled'])
  	}

  	scope :between_dates, -> (start_time, end_time) { where('start_time >= ? AND end_time <= ?', start_time, end_time) }

  	scope :with_joined_tables, -> {
  		select('stecms_appointment_bookings.*, stecms_appointment_customers.name as user_name, stecms_appointment_customers.name as user_surname')
  		.select('stecms_appointment_operators.operator_name AS operator_name, stecms_appointment_services.title')
  		.joins('LEFT JOIN stecms_appointment_operators ON stecms_appointment_operators.id = stecms_appointment_bookings.stecms_appointment_operator_id')
  		.joins('LEFT JOIN stecms_appointment_customers ON stecms_appointment_customers.id = stecms_appointment_bookings.stecms_appointment_customer_id')
  		.joins('LEFT JOIN stecms_appointment_services ON stecms_appointment_services.id = stecms_appointment_bookings.stecms_appointment_service_id')
  	}

  	attr_accessor :schedule_time, :booking_type, :schedule_date, :schedule_time_end, :employee_id, :booking, :guest_name, :guest_email, :guest_phone

  	def self.first_new_booking_online
  		first_new_booking_online =
  		self.where('start > ? AND tag = ?', Time.now.to_i, 'bookonline')
  		.where.not(status: ['cancelled', 'user_cancelled'], from_where: 'eva')
  		.order(created_at: :desc).first

  		first_new_booking_online || false
  	end

  	def self.get_calendar_bookings(start_time, end_time, operator_id)
  		start_time = Time.at(start_time.to_i).change(hour: 7).to_i

  		bookings = self.between_dates(start_time, end_time)
  		bookings = bookings.with_operator_id(operator_id) if operator_id.present?
  		bookings.any? ? bookings.generate_events_hashes : false
  	end

  	def self.generate_events_hashes
  		self.where(is_composed_treatment: false).map { |booking| booking.generate_event_hash }
  	end

  	def self.new_events_hashes(interval, resource_view, calendar_date, operator_id)
  		start_time, end_time = self.determine_times_by_resource_view(resource_view, calendar_date)
  		bookings = self.new_bookings(Time.now.to_i - interval.to_i, start_time, end_time)
  		bookings = bookings.with_operator_id(operator_id) if !operator_id.to_i.zero?
  		bookings.any? ? bookings.generate_events_hashes : false
  	end

  	def self.new_removed_events_hashes(interval, resource_view, calendar_date, operator_id)
  		start_time, end_time = self.determine_times_by_resource_view(resource_view, calendar_date)
  		bookings = self.new_removed_bookings(Time.now.to_i - interval.to_i, start_time, end_time)
  		bookings.with_operator_id(operator_id) if !operator_id.to_i.zero?
  		bookings.map { |booking| { id: booking.id } }
  	end

  	def self.determine_times_by_resource_view(resource_view, calendar_date)
  		start_time = Time.strptime(calendar_date, '%Y-%m-%d')

  		end_time =
  		if resource_view.eql? 'resourceDay'
  			start_time.end_of_day
  		else
  			start_time = start_time.beginning_of_week
  			start_time.end_of_week
  		end

  		[start_time.to_i, end_time.to_i]
  	end

  	def generate_reminder_file
  		current_time = Time.now
  		content = "BEGIN:VCALENDAR\n"+
  		"VERSION:2.0\n"+
  		"METHOD:PUBLISH\n"+
  		"BEGIN:VEVENT\n"+
  		"DTSTAMP:#{current_time.strftime("%Y%m%dT%H%M%SZ")}\n"+
  		"CREATED:#{current_time.strftime("%Y%m%dT%H%M%SZ")}\n"+
  		"UID:#{current_time.to_i}\n"+
  		"LAST-MODIFIED:#{current_time.strftime("%Y%m%dT%H%M%SZ")}\n"+
  		"DESCRIPTION:#{self.title} (#{self.duration / 60} min)\n"+
  		"SUMMARY:#{self.title} (#{self.duration / 60} min) da \n"+
  		"PRIORITY:1\n"+
  		"DTSTART:#{Time.at(self.start_time).strftime("%Y%m%dT%H%M%SZ")}\n"+
  		"DTEND:#{Time.at(self.end_time).strftime("%Y%m%dT%H%M%SZ")}\n"+
  		"TRANSP: OPAQUE\n"+
  		"SEQUENCE:0\n"+
  		"CLASS:PUBLIC\n"+
  		"BEGIN:VALARM\n"+
  		"DESCRIPTION:Reminder\n"+
  		"ACTION:DISPLAY\n"+
  		"TRIGGER;VALUE=DURATION:-PT240M\n"+
  		"END:VALARM\n"+
  		"END:VEVENT\n"+
  		"END:VCALENDAR\n"
  		file = "#{self.title} da #{self.id}.ics".gsub(/\//, " ")
  		file_path = File.join(Rails.root, 'public', 'reminder', file)
  		dirname = File.dirname(file_path)
  		Dir.mkdir(dirname) unless Dir.exist?(dirname)
  		File.open(file_path, "w"){ |f| f << content }
  		file_path
  	end

  	def verify_composed_booking
  		composed_treatments_data = self.service.try(:composed_treatments)
  		if composed_treatments_data.blank?
  			{status: true, composed: false}
  		else
  			verified = true
  			pause_setting_setting = self.service.pause_time_minutes.to_i
  			end_treatment_latest = nil
  			children_treatments = []
  			error_messages = []

  			composed_treatments_data.each_with_index do |composed_treatment, i|
  				treatment_obj = composed_treatment.children_treatment
  				if treatment_obj.present?
  					booking_new = self.dup.tap do |obj|
  						if i.zero?
  							obj.start_time = self.start_time
  							obj.duration = treatment_obj.duration
  							obj.end_time = obj.start_time + obj.duration
  						else
  							obj.start_time = end_treatment_latest
  							obj.duration = treatment_obj.duration
  							obj.end_time = obj.start_time + obj.duration
  						end

  						pause_time = composed_treatment.pause_time_minutes.zero? ? 0 : (composed_treatment.pause_time_minutes * 60)
  						end_treatment_latest = obj.end_time + pause_time

  						obj.service = treatment_obj
  					end

  					if booking_new.valid?
  						children_treatments << booking_new.attributes
  					else
  						verified = false
  						errors.add(:base, "failed because treatment #{treatment_obj.title} not available")
  					end
  				else
  					verified = false
  					errors.add(:base, "failed because treatment not found")
  				end
  			end

  			{status: verified, composed: true, result: children_treatments}
  		end
  	end

	  # Returns booking start date - on Time format
	  # It is stored as integer on database
	  #
	  def start_date
	  	Time.at(self.start_time) rescue nil
	  end

	  # Returns booking end date - on Time format
	  # It is stored as integer on database
	  #
	  def end_date
	  	Time.at(self.end_time) rescue nil
	  end

	  # Returns booking start time with format hour - minute - second
	  #
	  def start_time_to_s
	  	self.start_date.try(:strftime, '%H:%M:%S')
	  end

	  # Returns booking end time with format hour - minute - second
	  #
	  def end_time_to_s
	  	self.end_date.try(:strftime, '%H:%M:%S')
	  end

	  def operator_name
		if self.operator.present?
			self.operator.operator_name
		end		  
	  end

	  def set_title
	  	if self.service
	  		self.title = "#{self.service.title} (#{self.duration / 60} min)"
	  	end
	  end

	  def generate_event_hash(hide_buttons = false)

	  	booking = self
	  	booking_hash = {}

	  	category_treatment_id = booking.service.try(:id)

	  	if category_treatment_id
	  		special_category = true
	  	else
	  		special_category = false
	  	end

	  	start_date = Time.at(booking.start_time)
	  	end_date = Time.at(booking.end_time)
	  	duration = "#{ start_date.strftime("%H:%M")} - #{ end_date.strftime("%H:%M")}"
	  	duration << "(#{((booking.end_time - booking.start_time) / 60.0)} min)"

	  	booking_hash[:resourceId] = booking.stecms_appointment_operator_id
	  	booking_hash[:title] = "#{ booking.title }#{ booking.note.present? ? [' - ', booking.note].join : '' }"
	  	booking_hash[:start] = start_date.strftime("%Y-%m-%d %H:%M")
	  	booking_hash[:end] = end_date.strftime("%Y-%m-%d %H:%M")
	  	booking_hash[:allDay] = false
	  	booking_hash[:id] = booking.id
		
		if (user_booking_id = booking.user.user_id).present?
			user_id = user_booking_id
			role_user = User.where(id: user_id).first
			
			if user_id.present? && role_user.present?
				role_id = role_user.role_id
				if (role_user = User::Role.find(role_id)).present?
					booking_hash[:role_user] = role_user.name
					booking_hash[:role_user_color] = role_user.color_hex
				end
			end
		end


	  	hide_buttons = true if ['noshow', 'checkout'].include? booking.status

	    # binding.pry
	    if booking.tag.eql? 'busyTime'
	    	booking_hash[:description] = ''
	    	booking_hash[:name] = "Orario bloccato #{ start_date.strftime("%H:%M") } - #{ end_date.strftime("%H:%M") }"
	    	booking_hash[:className] = 'employeeBusyTime'
	    	booking_hash[:tag] = 'busyTime'
	    	booking_hash[:booking_form] = ApplicationController.new.render_to_string(partial: 'stecms_appointment/bookings/booking_form',
	    		locals: { booking: booking, hide_buttons: hide_buttons })
	    else
	    	name =
	    	if booking.user
	    		if booking.user.name.present?
	    			booking.user.name.titleize
	    		else
	    			'Nessun nome'
	    		end
	    	else
	    		'Occasionale'
	    	end

	    	if Time.now > end_date
	    		class_name = special_category ? 'category-special' : booking.status
	    	else
	    		if booking.tag.eql?('bookonline')
	    			class_name = "bookonline device-#{booking.from_where}"
	    		else
	    			class_name = special_category ? 'category-special' : booking.status
	    		end
	    	end

	    	booking_hash[:status] = booking.status
	    	booking_hash[:type] = 'ServiceBooking'
	    	booking_hash[:booking_type] = booking.user.present? ? 'customer' : 'Occasionale'
	    	booking_hash[:user] = name
	    	booking_hash[:name] = name
	    	booking_hash[:serviceId] = booking.stecms_appointment_service_id || 1
	    	booking_hash[:className] = class_name
	    	booking_hash[:tag] = 'bookonline'
	    	booking_hash[:booking_form] = ApplicationController.new.render_to_string(partial: 'stecms_appointment/bookings/booking_form',
	    		locals: { booking: booking, duration: duration, hide_buttons: hide_buttons })
	    end

	    puts booking_hash

	    booking_hash
	  end

	  def paypal_checkout_url(return_path)
	  	salon_setting = StecmsAppointment::Seting.first
	  	paypal_email = salon_setting.paypal_email.blank? ? 'paypal2016@salonist.it' : salon_setting.paypal_email
	  	values = {
	  		business: paypal_email,
	  		cmd: "_xclick",
	  		upload: 1,
	  		return: "#{ENV['site_host']}#{return_path}?item_number=#{self.booking_nr}",
	  		invoice: self.booking_id,
	  		amount: self.total_price,
	  		item_name: "Booking treatment",
	  		item_number: self.booking_nr,
	  		quantity: '1',
	  		currency_code: "EUR"
	  	}
	  	"#{ENV['paypal_host']}/cgi-bin/webscr?" + values.to_query
	  end

    def number_booking
      "ORD-"+ order
    end

    def generate_code_order
      self.order = Time.zone.now.to_i
    end

	  def self.data_master_is_ready?
	  	StecmsAppointment::Service.first.present? &&  StecmsAppointment::Operator.first.present? && StecmsAppointment::ServiceCategory.first.present?
	  end
	end
end
