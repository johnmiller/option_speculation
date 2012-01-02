require 'yaml'

dir = File.join(File.dirname(__FILE__), '.', 'lib')

Dir[File.expand_path("#{dir}/*.rb")].uniq.each do |file|
  require file
end

settings = YAML::load_file "settings.yml"

strategy_builder = StrategyBuilder.new settings
strategy_builder.find_current_best_picks
