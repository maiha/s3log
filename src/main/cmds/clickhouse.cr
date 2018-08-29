module Cmds::Clickhouse
  def self.run(buffer)
    options = S3Log::Parser::Option::Date | S3Log::Parser::Option::Header
    parser = S3Log::Parser.new(options: options)
    parser.parse(buffer) do |hash|
      puts hash.to_json
    end
  end
end
