module Cmds::Parse
  def self.run(buffer, options, dryrun : Bool = false)
    parser = S3Log::Parser.new(options)
    parser.parse(buffer) do |hash|
      STDOUT.puts hash.to_json if !dryrun
    end
    STDERR.puts parser.to_s if dryrun || parser.failure?
    exit 1 if parser.failure?
  end
end
