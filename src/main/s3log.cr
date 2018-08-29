require "../s3log"
require "./cmds/*"

options  = S3Log::Parser::Option::None
options |= S3Log::Parser::Option::Date if ARGV.delete("--date")
options |= S3Log::Parser::Option::Clickhouse if ARGV.delete("--clickhouse")
options |= S3Log::Parser::Option::FailFast if ARGV.delete("--fail-fast")

if ARGV.delete("--sample")
  Cmds::Sample.run
elsif ARGV.delete("--schema")
  Cmds::Schema.run(options)
elsif ARGV.delete("--json")
  Cmds::Parse.run(ARGF.gets_to_end, options)
else
end
