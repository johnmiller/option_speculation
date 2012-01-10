class StrategyBuilder

  def initialize(settings)
    @settings = settings
    @db = DataSession.new settings
  end

  def find_current_best_picks
    find_best_picks "20120101"
  end

  def find_best_picks(date)
    download_latest
    @db.rebuild_database
    import date
    calculate_20day_moving_average
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
    @db.execute_command %{#{@db.db_name} -c "UPDATE daily_stocks d SET twenty_day_mov_avg = (select avg(close) from daily_stocks d2 where d2.symbol = d.symbol );"}
  end
end
