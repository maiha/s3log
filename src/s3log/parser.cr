module S3Log
  class Parser
    # original: https://dev.classmethod.jp/etc/parsing-s3-server-access-log-file-final/
    REGEX = %r{^(?<bucketOwner>[\w]+) (?<bucket>[\w\-.]+|-) \[(?<timestamp>[a-zA-Z0-9/: \+]+)\] (?<remoteIp>[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) (?<requester>[\w\.\-:/]+|Anonymous) (?<requestId>[\w]+) (?<operation>[\w\.]+) (?<key>[^ ]+) "(?<requestScheme>(GET|PUT|POST|PATCH|DELETE|HEAD)) (?<requestPath>.*?) ?(?<requestProtocol>[\w/.]+)?" (?<status>[0-9]{3}) (?<errorCode>[\w\-]+|-) (?<bytesSent>[0-9]+|-) (?<objectSize>[0-9]+|-) (?<totalTime>[0-9]+|-) (?<turnAroundTime>[0-9]+|-) ("(?<referrer>(http(s)?://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?)|-)") (?<userAgent>"(.+|-)") (?<versionId>[\w-]+|-)$}m
    
    @[Flags]
    enum Option
      Clickhouse
      FailFast
    end

    Headers = REGEX.name_table.values

    property total   : Int32 = 0
    property success : Int32 = 0
    property failure : Int32 = 0
    
    def initialize(@options : Option = Option::None)
    end

    def headers : Array(String)
      if needs_date?
        ["date"] + Headers
      else
        Headers
      end
    end

    def parse(buffer : String)
      buffer.split(/\n/).each do |line|
        next if line.empty?
        @total += 1
        if md = REGEX.match(line)
          hash = md.named_captures
          process_date!(hash)
          @success += 1
          yield hash
        else
          if @options.fail_fast?
            abort line
          end
          @failure += 1
        end
      end
    end

    def to_s(io : IO)
      io << "total: #{@total}, success: #{@success}, failure: #{@failure}"
    end

    private def process_date!(hash)
      return unless needs_date?
      if v = hash["timestamp"]?
        # 29/Aug/2018:15:00:36 +0000
        time = Time.parse(v, "%d/%b/%Y:%H:%M:%S %z", Time::Location.local).to_local
        hash["date"] = time.to_s("%Y-%m-%d")
        hash["timestamp"] = time.to_s
      end
    end

    private def needs_date?
      @options.clickhouse?
    end
  end
end
