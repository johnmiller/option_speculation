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
    import_fileset("stockquotes", "daily_stocks")
    import_fileset("options", "daily_options")
    import_fileset("optionstats", "daily_volatility")
  end

  def import_fileset(file_prefix, table_name)
    Dir.glob("#{@import_dir}/#{file_prefix}_*.csv").each do |file|
      @db.import_file file, table_name
    end
  end

  def cleanup()
    system "rm -rf #{@import_dir}"
  end

  def bash_safe_path(path)
    path.gsub(" ", "\\ ")
  end
end