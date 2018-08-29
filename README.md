# s3log

Utilities for the S3 access log files.

## Usage

```console
### convert to json, where LOG_FILE is like '2018-08-29-16-33-...'
$ s3log --json LOG_FILE > log.json
```

## Play with ClickHouse

```console
### create table named "s3logs"
$ s3log --schema --clickhouse | clickhouse-client

### insert
$ s3log --clickhouse LOG_FILE | clickhouse-client --query="INSERT INTO s3logs FORMAT JSONEachRow"

### play
:) select requestScheme,count(*) from s3logs group by requestScheme;
┌─requestScheme─┬─count()─┐
│ GET           │    2284 │
│ PUT           │       1 │
│ HEAD          │    1070 │
│ DELETE        │       1 │
└───────────────┴─────────┘
```

## Compile

```console
make build
```

## Contributing

1. Fork it (<https://github.com/maiha/s3log/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [maiha](https://github.com/maiha) maiha - creator, maintainer
