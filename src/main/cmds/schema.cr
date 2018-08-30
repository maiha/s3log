class Cmds::Schema
  DEFAULT_COLUMN_TYPE = "String"
  SPECIAL_COLUMN_TYPES = {
    "date"      => "Date",
    "timestamp" => "DateTime",
  }
  
  def initialize(@option : S3Log::Parser::Option, @table_name : String, @merge : Bool)
  end

  def run
    if @option.clickhouse?
      puts clickhouse_schema
    else
      puts headers
    end
  end

  def headers : Array(String)
    S3Log::Parser.new(@option).headers
  end

  def clickhouse_schema : String
    String.build do |io|
      io << "CREATE TABLE IF NOT EXISTS %s\n" % @table_name
      io << "(\n"
      io << headers.map{|key| "    %s %s" % [key, column_type(key)]}.join(",\n") << "\n"
      io << ")\n"
      if @merge
        io << "ENGINE = Merge(currentDatabase(), '^%s_')\n" % [@table_name, @table_name]
      else
        io << "ENGINE = MergeTree(date, timestamp, 8192)\n"
      end
    end    
  end

  def column_type(key : String) : String
    SPECIAL_COLUMN_TYPES[key]? || DEFAULT_COLUMN_TYPE
  end
end
