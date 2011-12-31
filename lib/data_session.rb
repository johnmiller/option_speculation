require 'pg'

class DataSession

  def initialize(settings)
    @settings = settings
    db_settings = @settings["database"]
    @db_name = db_settings["name"]
  end

  def rebuild_database
    drop_database
    create_database
    create_tables
  end

  def drop_database
    system "psql -e -c 'DROP DATABASE IF EXISTS #{@db_name};'"
  end

  def create_database
    system "psql -e -c 'CREATE DATABASE #{@db_name};'"
  end

  def create_tables
    system "psql #{@db_name} -f db/create_schema.sql"
  end
end
