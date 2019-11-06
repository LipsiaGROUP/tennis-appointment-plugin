$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "stecms_appointment/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "stecms_appointment"
  s.version     = StecmsAppointment::VERSION
  s.authors     = ["lipsiagroup"]
  s.email       = ["info@lipsiagroup.com"]
  s.homepage    = "http://lipsiagroup.it"
  s.summary     = "Appointment module of STECMS"
  s.description = "Appointment module of STECMS"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.10"
  s.add_dependency "ancestry", "3.0.7"
  s.add_dependency "simple_form",  "4.0.0"
  s.add_dependency "cocoon",  "1.2.14"
end
