module StecmsAppointment
  module Frontend

    class AppointmentServicesController < FrontendController
      helper StecmsAppointment::ApplicationHelper
      before_action :find_service, except: [:create, :show, :reminder_booking, :index]
      skip_before_action :redirects, except: [:new]


      def index
        @services = ::StecmsAppointment::Service.active
        @salon_work_days = ::StecmsAppointment::BusinessHour.get_schedule
      end

      def new
      	@booking = ::StecmsAppointment::Booking.new
      	date = Time.now
        treatment_data = {
          treatment_id: @service.id,
          duration: @service.duration
        }
        date_parsed = date.strftime("%d/%m/%Y")
        @month = date.month
        @year = date.year
        @date_value = date.strftime("%m/%d/%Y")
        # @is_mobile = browser.device.mobile?
        @calendar_content = CalendarBooking.date_month_content(@month, @year)
        @operators = ::StecmsAppointment::Operator.get_available_operators_for_treatment(treatment_data, date_parsed)

        if params['iframe_layout'].present?
          @iframe_layout = true
          response.headers.delete('X-Frame-Options')
          response.headers["X-FRAME-OPTIONS"] = 'ALLOWALL'
        end
      end

      def change_month_calendar
        current_date = Time.now
        treatment_data = {
          treatment_id: @service.id,
          duration: @service.duration
        }
        @month = params[:month].to_i
        @year = params[:year].to_i
        @calendar_content = CalendarBooking.date_month_content(@month, @year)

        if current_date.month.eql?(@month) and current_date.year.eql?(@year)
          string_date = "#{current_date.day}/#{@month}/#{@year}"
          @date_value = "#{@month}/#{current_date.day}/#{@year}"
        else
          string_date = "1/#{@month}/#{@year}"
          @date_value = "#{@month}/1/#{@year}"
        end

        @operators = ::StecmsAppointment::Operator.get_available_operators_for_treatment(treatment_data, string_date)

        render layout: false
      end

      def change_date_calendar
        treatment_data = {
          treatment_id: @service.id,
          duration: @service.duration
        }
        @operators = ::StecmsAppointment::Operator.get_available_operators_for_treatment(treatment_data, params[:date])
        date = params[:date].split("/")
        @date_value = "#{date[1]}/#{date[0]}/#{date[2]}"
        render layout: false
      end

      # generate booking reminder and automatically downloaded with .ics format to be upload to google calendar
      #
      def reminder_booking
        if params['iframe_layout'].present?
          @iframe_layout = true
          response.headers.delete('X-Frame-Options')
          response.headers["X-FRAME-OPTIONS"] = 'ALLOWALL'
        end
        booking = ::StecmsAppointment::Booking.find(params[:id])
        file_path = booking.generate_reminder_file
        puts file_path
        send_file(file_path)
      end

      def create
        @error = true
        url_hash = {treatment: params[:booking][:stecms_appointment_service_id]}
        if params['iframe_layout'].present?
          url_hash[:iframe_layout] = true
          response.headers.delete('X-Frame-Options')
          @iframe_layout = true
          response.headers["X-FRAME-OPTIONS"] = 'ALLOWALL'
        end

        booking_params.delete(:guest_name)
        booking_params.delete(:guest_email)
        booking_params.delete(:guest_phone)

        booking = ::StecmsAppointment::Booking.new(booking_params)
        booking.status = 'confirmed'
        booking.from_where = 'website'
        booking.tag = 'booking'
        booking.note = ''
        if !user_signed_in?
          if params[:booking][:guest_name].blank? or params[:booking][:guest_email].blank? or params[:booking][:guest_phone].blank?
            respond_to do |format|
              format.js { render layout: false }
              format.html { redirect_to new_frontend_appointment_service_url(url_hash), alert: 'Compila tutti i campi per favore' }
            end

            return false
          else
            check_user = User.where(email: params[:booking][:guest_email]).first
            if check_user
              user = check_user

              customer = ::StecmsAppointment::Customer.where(email: user.email).last
              unless customer
                customer = ::StecmsAppointment::Customer.create(email: user.email, cell: params[:booking][:guest_phone], name: params[:booking][:guest_name])
              end

              booking.stecms_appointment_customer_id = customer.try(:id)
            else
              check_user = ::StecmsAppointment::Customer.where(email: params[:booking][:guest_email]).first
              if check_user
                booking.stecms_appointment_customer_id = check_user.id
              else
                customer = ::StecmsAppointment::Customer.new(email: params[:booking][:guest_email], cell: params[:booking][:guest_phone], name: params[:booking][:guest_name])

                if customer.save(validate: false)
                  booking.stecms_appointment_customer_id = customer.id
                end
              end
            end
          end
        else
          customer = current_user
        end

        customer = ::StecmsAppointment::Customer.where(email: customer.email).last
        booking.stecms_appointment_customer_id = customer.try(:id)
        service = ::StecmsAppointment::Service.find(booking_params[:stecms_appointment_service_id])
        booking.title = service.title + " (" + (service.duration / 60).to_s + " min)"
        booking.duration = service.duration
        booking.stecms_appointment_service_id = service.id

        composed_booking = booking.verify_composed_booking
        if booking.valid? and composed_booking[:status]
          booking.save
          if composed_booking[:composed]
            composed_booking[:result].each do |compose_booking_attr|
              compose_booking_attr.delete('ancestry')
              booking.children.create(compose_booking_attr)
            end
            booking.is_composed_treatment = true
            booking.save
          end

          if params[:payment_method].eql?('paga-subito')
            redirect_to booking.paypal_checkout_url(return_feedback_path)
          else
            url_success_hash = {}
            url_success_hash[:iframe_layout] = true if params['iframe_layout'].present?

            @url_redirect = frontend_appointment_service_url(booking, url_success_hash)
          end

          @error = false

          respond_to do |format|
            format.js { render layout: false }
            format.html { redirect_to @url_redirect, notice: I18n.t('La prenotazione è stata creata con successo') }
          end

        else
          respond_to do |format|
            format.js { render layout: false }
            format.html { redirect_to new_frontend_appointment_service_url(url_hash), alert: 'Compila tutti i campi per favore' }
          end
        end
      end

      def show
        @booking = ::StecmsAppointment::Booking.find(params[:id])
        if params['iframe_layout'].present?
          @iframe_layout = true
          response.headers.delete('X-Frame-Options')
          response.headers["X-FRAME-OPTIONS"] = 'ALLOWALL'
        end
      end

      private

      def booking_params
          params.require(:booking).permit(:stecms_appointment_operator_id, :start_time, :end_time, :stecms_appointment_service_id, :price,
            :discount_type, :discount_value, :discount_price, :voucher_id, :voucher_value, :vouchered_price, :note, :promo_code, :mobile, :guest_name, :guest_email, :guest_phone)
      end

      def find_service
        @service = ::StecmsAppointment::Service.find(params[:treatment])
      end

    end

  end
end
