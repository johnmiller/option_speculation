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
end
