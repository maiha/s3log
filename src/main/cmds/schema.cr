class Cmds::Schema
  def self.run(option, table_name : String)
    new(option, table_name).run
  end

  DEFAULT_COLUMN_TYPE = "String"
  SPECIAL_COLUMN_TYPES = {
    "date"      => "Date",
    "timestamp" => "DateTime",
  }
  
  def initialize(@option : S3Log::Parser::Option, @table_name : String)
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
      io << "ATTACH TABLE %s\n" % @table_name
      io << "(\n"
      io << headers.map{|key| "    %s %s" % [key, column_type(key)]}
                    .join(",\n") << "\n"
      io << ")\n"
      io << "ENGINE = MergeTree(date, timestamp, 8192)\n"
    end    
  end

  def column_type(key : String) : String
    SPECIAL_COLUMN_TYPES[key]? || DEFAULT_COLUMN_TYPE
  end
end
