module Cmds::Schema
  def self.run(options)
    if options.clickhouse?
      puts clickhouse(headers(options))
    else
      puts headers(options)
    end
  end

  def self.headers(options)
    S3Log::Parser.new(options).headers
  end

  def self.clickhouse(keys) : String
    String.build do |io|
      io << "ATTACH TABLE s3logs\n"
      io << "(\n"
      io << keys.map{|key|
        val = (key == "date") ? "Date" : "String"
        "    %s %s" % [key, val]
      }.join(",\n") << "\n"
      io << ")\n"
      io << "ENGINE = MergeTree(date, (timestamp, key), 8192)\n"
    end    
  end
end
