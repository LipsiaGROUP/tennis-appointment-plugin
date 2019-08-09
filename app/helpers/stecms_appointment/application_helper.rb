module StecmsAppointment
  module ApplicationHelper
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
