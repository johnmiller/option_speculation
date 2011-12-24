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

  def download_options_for(date)
    file = "options_#{date.strftime('%Y%m%d')}.zip"
    download file
  end

  def download_missing_options()
    connect
    missing_files.each{|file| get file}
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
    @ftp.getbinaryfile(file, "#{@settings['source_zip_dir']}/#{file}", 1024)
  end

  def missing_files
    remote_files = @ftp.nlst('options_*.zip')
    local_files = Dir.entries @settings['source_zip_dir']
    remote_files - local_files
  end
end
