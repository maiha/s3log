require "../s3log"
require "./cmds/*"

class Main
  include Opts

  CMDS  = %w( json sample schema ).sort
  USAGE = <<-EOF
    {{version}}

    Usage: {{program}} <command> [options] [args]

    command:
      json    convert the log file to json
      sample  show sample data
      schema  show field names in json

    options:
    {{options}}

    Examples:
      s3log json LOG_FILE > log.json
      s3log schema --clickhouse | clickhouse-client
      s3log json --clickhouse LOG_FILE | clickhouse-client --query="INSERT INTO s3logs FORMAT JSONEachRow"
    EOF

  option clickhouse : Bool, "--clickhouse", "ClickHouse mode", false
  option failfast   : Bool, "--fail-fast", "Abort the run on first failure", false
  option dryrun     : Bool, "-n", "Dryrun for check", false
  option help       : Bool, "--help"   , "Show this help", false
  option version    : Bool, "--version", "Print the version and exit", false

  property parse_options : S3Log::Parser::Option = S3Log::Parser::Option::None
  
  def setup
    self.parse_options |= S3Log::Parser::Option::Clickhouse if clickhouse?
    self.parse_options |= S3Log::Parser::Option::FailFast   if failfast?
    super
  end

  def run
    case args.shift?
    when "json"
      Cmds::Parse.run(ARGF.gets_to_end, parse_options, dryrun: dryrun?)
    when "sample"
      Cmds::Sample.run
    when "schema"
      Cmds::Schema.run(parse_options)
    else
      abort "ERROR: No commands\nExpected one of: %s" % CMDS.join(", ")
    end
  end
end

Main.run
