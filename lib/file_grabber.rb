require 'net/ftp'

class FileGrabber

  def initialize(settings)
    @settings = settings
  end

  def download(file)
    connect
    get file
    close
  end

  def download_todays_options()
    download_options_for Time.now
  end

  def download_latest_options
    connect
    file = find_last_remote_file

    if find_local_files.include? file
      puts "Latest file has already been downloaded. File: #{file}"
    else
      get file
    end

    close
  end

  def download_options_for(date)
    file = "options_#{date.strftime('%Y%m%d')}.zip"
    download file
  end

  def download_new_options()
    connect
    files_to_download = find_missing_files

    if files_to_download.empty?
      puts "No new files to download"
    else
      files_to_download.each{|file| get file}
    end

    close
  end

  private

  def connect()
    ftp_settings = @settings["ftp"]
    @ftp = Net::FTP.new(ftp_settings["url"])
    @ftp.login ftp_settings["user"], ftp_settings["password"]
    @ftp.chdir('dbupdate')
  end

  def close
    @ftp.close
  end

  def get(file)
    puts "Downloading #{file}"
    @ftp.getbinaryfile(file, "#{@settings['source_zip_dir']}/#{file}", 1024)
  end

  def find_missing_files
    find_remote_files - find_local_files
  end

  def find_remote_files
    @ftp.nlst('options_*.zip')
  end

  def find_local_files
    Dir.entries @settings['source_zip_dir']
  end

  def find_last_remote_file
    find_remote_files.sort.last
  end
end
