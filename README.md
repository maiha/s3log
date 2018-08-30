# s3log

Utilities for the S3 access log files.

## Usage

```
Usage: s3log [options] <command>

command:
  json    convert the log file to json
  sample  show sample data
  schema  show field names in json
  
options:
  --clickhouse  ClickHouse mode.
  --fail-fast   Abort the run on first failure.
  --help        Show this help.
  --version     Print the version and exit.
```

## JSONify

convert to json, where LOG_FILE is like `2018-08-29-16-33-...`.

```console
$ cat LOG_FILE
abc backet [29/Aug/2018:15:00:36 +0000] 0.0.0.0 arn:aws:sts::1:role 1 REST.HEAD.OBJECT key "HEAD /path HTTP/1.1" 200 - - 0 10 - "-" "agent" -
...

$ s3log json LOG_FILE
{"bucketOwner":"abc","bucket":"backet","timestamp":"29/Aug/20...

$ s3log json LOG_FILE | jq '.requestScheme'
"HEAD"
"GET"
"HEAD"
...
```

## Play with ClickHouse

```console
### create table named "s3logs"
$ s3log schema --clickhouse | clickhouse-client

### insert
$ s3log json --clickhouse LOG_FILE | clickhouse-client --query="INSERT INTO s3logs FORMAT JSONEachRow"

### play
:) select requestScheme,count(*) from s3logs group by requestScheme;
┌─requestScheme─┬─count()─┐
│ GET           │    2284 │
│ PUT           │       1 │
│ HEAD          │    1070 │
│ DELETE        │       1 │
└───────────────┴─────────┘
```

It'd be better to create dated tables for production use.
Here, we assume that all log files of '2018-08-29-*' are stored in `2018-08-29/` dir.
```console
### create dated table
$ s3log schema --clickhouse --table "s3logs_20180829" | clickhouse-client

### create merge table
$ s3log schema --clickhouse --table "s3logs" --merge | clickhouse-client

### import with idempotency (replace the table)
$ clickhouse-client --query="DROP TABLE IF EXISTS s3logs_20180829"
$ cat 2018-08-29/* | s3log json --clickhouse | clickhouse-client --query="INSERT INTO s3logs_20180829 FORMAT JSONEachRow"

### play with distributed table "s3logs"
$ clickhouse-client --query="show tables"
s3logs
s3logs_20180828
s3logs_20180829
```

## Compile

```console
make build
```

## Contributing

1. Fork it (https://github.com/maiha/s3log/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
