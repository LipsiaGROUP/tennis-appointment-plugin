module StecmsAppointment
  module ServicesHelper

  	EURO = '&euro;'.html_safe
  	DISCOUNT_TYPE = [['%', '%'], [EURO, 'euro']]

  	def days_of_week
      ["Domenica", "Lunedì", "Martedì", "Mercoledì", "Giovedì",
      "Venerdì", "Sabato"]
    end
  end
end
