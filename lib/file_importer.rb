class FileImporter

  def initialize(settings)
    @settings = settings
    @import_dir = bash_safe_path @settings["import_dir"]
    @source_dir = bash_safe_path @settings["source_zip_dir"]
    @db = DataSession.new @settings
  end

  def import(date, num_of_days)
    cleanup
    extract_files(date, num_of_days)
    import_pending_files
    cleanup
  end

  def extract_files(date, num_of_days)
    cleanup
    zip_files = Dir.glob("#{@source_dir}/options_*.zip")
                   .sort
                   .reverse
                   .select{|x| x[/[0-9]{8}/] <= date}
                   .take(num_of_days)

    zip_files.each do |file|
      system "unzip #{bash_safe_path(file)} -d #{@import_dir}"
    end
  end

  def import_pending_files()
    import_stock_files
    import_option_files
    import_volatility_files
  end

  def import_stock_files()
    Dir.glob("#{@import_dir}/stockquotes_*.csv").each do |file|
      @db.execute_command %{#{@db.db_name} -c "COPY daily_stocks (symbol, date, open, high, low, close, volume) FROM '#{file}' DELIMITER ',' CSV"}
    end
  end

  def import_option_files()
    Dir.glob("#{@import_dir}/options_*.csv").each do |file|
      @db.execute_command %{#{@db.db_name} -c "COPY daily_options FROM '#{file}' DELIMITER ',' CSV"}
    end
  end

  def import_volatility_files()
    Dir.glob("#{@import_dir}/optionstats_*.csv").each do |file|
      @db.execute_command %{#{@db.db_name} -c "COPY daily_volatility FROM '#{file}' DELIMITER ',' CSV"}
    end
  end

  def cleanup()
    system "rm -rf #{@import_dir}"
  end

  def bash_safe_path(path)
    path.gsub(" ", "\\ ")
  end
end
