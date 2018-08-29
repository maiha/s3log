require "json"

module S3Log
  SAMPLE = {{ system("cat " + env("PWD") + "/sample/log").stringify }}
end

require "./s3log/*"

