
# fluent-plugin-mysql-bulk [![Build Status](https://secure.travis-ci.org/toyama0919/fluent-plugin-mysql-bulk.png?branch=master)](http://travis-ci.org/toyama0919/fluent-plugin-mysql-bulk)

fluent plugin mysql bulk insert is high performance and on duplicate key update respond.

## Installation

### td-agent(Linux)

    /usr/lib64/fluent/ruby/bin/fluent-gem install fluent-plugin-mysql-bulk

### td-agent(Mac)

    sudo /usr/local/Cellar/td-agent/1.1.XX/bin/fluent-gem install fluent-plugin-mysql-bulk

### fluentd only

    gem install fluent-plugin-mysql-bulk


## Parameters

param|value
--------|------
host|database host(default: 127.0.0.1)
database|database name(require)
username|user(require)
password|password(default: blank)
key_names|bulk insert column (require)
table|bulk insert table (require)
on_duplicate_key_update|on duplicate key update enable (true:false)
on_duplicate_update_keys|on duplicate key update column, comma separator

## Configuration Example(bulk insert)

```
<match mysql.input>
  type mysql_bulk
  host localhost
  database test_app_development
  username root
  password hogehoge
  key_names id,user_name,created_at,updated_at
  table users
  flush_interval 10s
</match>
```

Assume following input is coming:

```js
mysql.input: {"user_name":"toyama","created_at":"2014/01/03 21:35:15","updated_at":"2014/01/03 21:35:15","dummy":"hogehoge"}
mysql.input: {"user_name":"toyama2","created_at":"2014/01/03 21:35:21","updated_at":"2014/01/03 21:35:21","dummy":"hogehoge"}
mysql.input: {"user_name":"toyama3","created_at":"2014/01/03 21:35:27","updated_at":"2014/01/03 21:35:27","dummy":"hogehoge"}
```

then result becomes as below (indented):

```sql
+-----+-----------+---------------------+---------------------+
| id  | user_name | created_at          | updated_at          |
+-----+-----------+---------------------+---------------------+
| 1   | toyama    | 2014-01-03 21:35:15 | 2014-01-03 21:35:15 |
| 2   | toyama2   | 2014-01-03 21:35:21 | 2014-01-03 21:35:21 |
| 3   | toyama3   | 2014-01-03 21:35:27 | 2014-01-03 21:35:27 |
+-----+-----------+---------------------+---------------------+
```

running query

```sql
INSERT INTO users (id,user_name,created_at,updated_at) VALUES (NULL,'toyama','2014/01/03 21:35:15','2014/01/03 21:35:15'),(NULL,'toyama2','2014/01/03 21:35:21','2014/01/03 21:35:21')
```

## Configuration Example(bulk insert , if duplicate error record update)

```
<match mysql.input>
  type mysql_bulk
  host localhost
  database test_app_development
  username root
  password hogehoge
  key_names id,user_name,created_at,updated_at
  table users
  on_duplicate_key_update true
  on_duplicate_update_keys user_name,updated_at
  flush_interval 60s
</match>
```

Assume following input is coming:

```js
mysql.input: {"id":"1" ,"user_name":"toyama7","created_at":"2014/01/03 21:58:03","updated_at":"2014/01/03 21:58:03"}
mysql.input: {"id":"2" ,"user_name":"toyama7","created_at":"2014/01/03 21:58:06","updated_at":"2014/01/03 21:58:06"}
mysql.input: {"id":"3" ,"user_name":"toyama7","created_at":"2014/01/03 21:58:08","updated_at":"2014/01/03 21:58:08"}
mysql.input: {"id":"10","user_name":"toyama7","created_at":"2014/01/03 21:58:18","updated_at":"2014/01/03 21:58:18"}
```

then result becomes as below (indented):

```sql
+-----+-----------+---------------------+---------------------+
| id  | user_name | created_at          | updated_at          |
+-----+-----------+---------------------+---------------------+
|   1 | toyama7   | 2014-01-03 21:35:15 | 2014-01-03 21:58:03 |
|   2 | toyama7   | 2014-01-03 21:35:21 | 2014-01-03 21:58:06 |
|   3 | toyama7   | 2014-01-03 21:35:27 | 2014-01-03 21:58:08 |
|  10 | toyama7   | 2014-01-03 21:58:18 | 2014-01-03 21:58:18 |
+-----+-----------+---------------------+---------------------+
```

if duplicate id , update username and updated_at



## spec

```
bundle install
rake test
```

## todo

divide bulk insert(exsample 1000 per)


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new [Pull Request](../../pull/new/master)

## Copyright

Copyright (c) 2013 Hiroshi Toyama. See [LICENSE](LICENSE) for details.
