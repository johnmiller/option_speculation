class FileExtractor
  
  def initialize(settings)
    @settings = settings
  end
  
  def extract_zipped_options() 
    zipped_files = Dir.entries "#{@settings["source_zip_dir"]}/options_*.zip"
    p zipped_files
  end
end
