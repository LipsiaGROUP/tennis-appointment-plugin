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
  end
end
