module StecmsAppointment
  class ApplicationController < ActionController::Base
  	helper ::BackendHelper
    protect_from_forgery with: :exception
  end
end
