require 'yaml'

dir = File.join(File.dirname(__FILE__), '.', 'lib')

Dir[File.expand_path("#{dir}/*.rb")].uniq.each do |file|
  require file
end

settings = YAML::load_file "settings.yml"

file_grabber = FileGrabber.new settings
#file_grabber.download_options_for(Time.now - 86400)
file_grabber.download_missing_options
