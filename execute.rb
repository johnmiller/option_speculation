require 'yaml'
require 'optparse'

def require_files
	dir = File.join(File.dirname(__FILE__), '.', 'lib')

	Dir[File.expand_path("#{dir}/*.rb")].uniq.each do |file|
	  require file
	end
end

def load_settings
	@settings = YAML::load_file "settings.yml"
end

def parse_args
	@args = {}

	opt_parser = OptionParser.new do |opts|
		opts.banner = "Usage: execute.rb [options]"
		opts.separator ""
	    opts.separator "Specific options:"

		opts.on("-r", "--rebuild-database", "Drops and recreates the database") do
			@args[:rebuild_db] = true 
		end

		opts.on("-m", "--download-missing", "Downloads options files that exist", " on server but not locally") do
			@args[:download_missing] = true;
		end

		opts.on("-l", "--download-latest", "Downloads newest options files from remote server") do
			@args[:download_latest] = true;
		end

		opts.on("-d", "--import DIR", "Imports files in specified directory") do |x|
			@args[:import_dir] = x;
		end

		opts.on("-h", "--help", "Display help") do
			puts opts
			exit
		end
	end

	opt_parser.parse!
end

def rebuild_db
	puts "Rebuilding database"
	db = DataSession.new @settings
	db.rebuild_database
end

def download_missing_options
	puts "Downloading missing files"
	file_grabber = FileGrabber.new @settings
    file_grabber.download_new_options
end

def download_latest_options
	puts "Downloading latest options file"
	file_grabber = FileGrabber.new @settings
    file_grabber.download_latest_options
end

def import_dir(dir)
	file_importer = FileImporter.new @settings
    file_importer.import_dir dir
end

require_files
load_settings
parse_args

rebuild_db if @args[:rebuild_db]
download_latest_options if @args[:download_latest]
download_missing_options if @args[:download_missing]
import_dir @args[:import_dir] if @args[:import_dir]

#strategy_builder = StrategyBuilder.new @settings
#strategy_builder.download_latest
#strategy_builder.find_best_picks "20130412"
