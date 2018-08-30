class Cmds::Schema
  def self.run(options, table_name : String)
    new(options, table_name).run
  end

  def initialize(@options : S3Log::Parser::Option, @table_name : String)
  end

  def run
    if @options.clickhouse?
      puts clickhouse_schema
    else
      puts headers
    end
  end

  def headers : Array(String)
    S3Log::Parser.new(@options).headers
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
    case key
    when "date"; "Date"
    else       ; "String"
    end        
  end
end
