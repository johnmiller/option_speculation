require 'pg'

class DataSession
  attr_accessor :db_name

  def initialize(settings)
    @settings = settings
    @import_dir = @settings["import_dir"]
    db_settings = @settings["database"]
    @db_name = db_settings["name"]
    @verbose = db_settings["verbose"]
    @user_name = db_settings["user"]
  end

  def rebuild_database
    drop_database
    create_database
    create_tables
  end

  def drop_database
    execute_command "postgres -c 'DROP DATABASE IF EXISTS #{@db_name};'"
  end

  def create_database
    execute_command "postgres -c 'CREATE DATABASE #{@db_name};'"
  end

  def create_tables
    execute_command "#{@db_name} -f db/create_schema.sql"
  end

  def execute_command(cmd)
    cmd = "-e #{cmd}" if @verbose
    system "psql -q --no-password -U #{@user_name} #{cmd}"
  end
end
