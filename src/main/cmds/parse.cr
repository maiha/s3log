module Cmds::Parse
  def self.run(buffer, options)
    parser = S3Log::Parser.new(options)
    parser.parse(buffer) do |hash|
      STDOUT.puts hash.to_json
    end
    STDERR.puts parser.to_s
    exit 1 if parser.failure > 0
  end
end
