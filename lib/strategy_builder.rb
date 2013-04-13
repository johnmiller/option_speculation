class StrategyBuilder

  def initialize(settings)
    @settings = settings
    @db = DataSession.new settings
  end

  def find_current_best_picks
    find_best_picks "20120306"
  end

  def find_best_picks(date)
    #download_latest
    @db.rebuild_database
    #import date
    #calculate_20day_moving_average
  end

  def download_latest()
    return if !@settings["download_latest"]
    file_grabber = FileGrabber.new @settings
    file_grabber.download_new_options
  end

  def import(date)
    file_importer = FileImporter.new @settings
    file_importer.import date, @settings["num_of_days"]
  end

  def calculate_20day_moving_average()
    #TODO: Change back to 20 days instead of 2
    @db.execute_command %{#{@db.db_name} -c "UPDATE daily_stocks d SET twenty_day_mov_avg = (select avg(close) from daily_stocks d2 where d2.symbol = d.symbol limit 20);"}
  end

  def calculate_20day_standard_deviation()
    @db.execute_command %{#{@db.db_name} -c "update daily_stocks d set twenty_day_stand_dev_times_two = (select stddev_pop(close) * 2 from daily_stocks d2 where d2.symbol = d.symbol and d2.date < d.date limit 20);"}
  end

  def calculate_bollinger_bands()

  end
end
