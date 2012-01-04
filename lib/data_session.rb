require 'pg'

class DataSession

  def initialize(settings)
    @settings = settings
    @import_dir = @settings["import_dir"]
    db_settings = @settings["database"]
    @db_name = db_settings["name"]
    @verbose = db_settings["verbose"]
  end

  def rebuild_database
    drop_database
    create_database
    create_tables
  end

  def import_file(file, table_name)
      execute_command %{#{@db_name} -c "COPY #{table_name} FROM '#{file}' DELIMITER ',' CSV"}
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
    system "psql #{cmd}"
  end
end
