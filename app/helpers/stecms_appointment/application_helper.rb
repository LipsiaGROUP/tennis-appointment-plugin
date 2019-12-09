module StecmsAppointment
  module ApplicationHelper

    def booking_date_time_integer_format(date, time)
      booking_date_splitted = date.split("/")
      booking_time_splitted = time.split(":")
      booking_date_time = Time.new(booking_date_splitted[2].to_i, booking_date_splitted[0].to_i, booking_date_splitted[1].to_i, booking_time_splitted[0], booking_time_splitted[1]).to_i
      return booking_date_time
    end

    def get_payment_options(treatment)
      payment_options = {
        in_salon: {
          id: 'paga-salone', text: 'Paga in salone'
        }
      }
      payment_options.merge!({electronic_card: {id: 'paga-subito', text: 'Paga con carta'}}) if treatment.price.to_i
      payment_options
    end

    def get_notice(type, message, style = nil)
      notice_class =
      case type
      when 'notice' then 'success'
      when 'warning' then 'warning'
      else 'error'
      end

      content_tag(:div, class: 'notice', style: style) do
        content_tag(:div, class: "alert alert-#{notice_class}") do
          [message, content_tag(:a, '×', class:'close', data: { dismiss: 'alert' })].join.html_safe
        end
      end
    end


    def method_missing method, *args, &block
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        if main_app.respond_to?(method)
          main_app.send(method, *args)
        else
          super
        end
      else
        super
      end
    end

    def respond_to?(method)
      if method.to_s.end_with?('_path') or method.to_s.end_with?('_url')
        if main_app.respond_to?(method)
          true
        else
          super
        end
      else
        super
      end
    end

  end
end
