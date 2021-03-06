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

  def import_dir(dir)
    zip_files = Dir.glob("#{dir}/**/options_*.zip")

    zip_files.each do |file|
      puts "Importing #{file}"
      cleanup
      unzip file
      import_pending_files
    end
    
    mark_current
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
      unzip file
    end
  end

  def import_pending_files()
    cmd = %{#{@db.db_name} -c "}

    Dir.glob("#{@import_dir}/stockquotes_*.csv").each do |file|
      cmd += "COPY daily_stocks (symbol, date, open, high, low, close, volume) "
      cmd += "FROM '#{file}' DELIMITER ',' CSV;"
    end
 
    Dir.glob("#{@import_dir}/options_*.csv").each do |file|
      cmd += "COPY daily_options (underlying, underlying_last, exchange, "
      cmd += "option_symbol, blank, option_type, expiration_date, "
      cmd += "quote_date, strike, last, bid, ask, volume, open_interest, "
      cmd += "implied_volatility, delta, gamma, theta, vega, alias) "
      cmd += "FROM '#{file}' DELIMITER ',' CSV;"
    end
  
    Dir.glob("#{@import_dir}/optionstats_*.csv").each do |file|
      cmd += "COPY daily_volatility (symbol, date, call_iv, put_iv, "
      cmd += "mean_iv, call_vol, put_vol, call_oi, put_oi) "
      cmd += "FROM '#{file}' DELIMITER ',' CSV;"
    end

    cmd += '"';
    @db.execute_command cmd
  end

  def mark_current()
    puts "Flagging most recent quotes"
    @db.execute_command %{#{@db.db_name} -c "SELECT mark_current();"}
  end

  def cleanup()
    system "rm -rf #{@import_dir}"
  end

  def unzip(file)
    system "unzip -q #{bash_safe_path(file)} -d #{@import_dir}"
  end

  def bash_safe_path(path)
    path.gsub(" ", "\\ ")
  end
end
