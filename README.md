# influxdb-lineprotocol-writer-ruby
A Ruby Library for Writing to InfluxDB v0.9+ using the new Line Protocol (https://github.com/influxdb/influxdb/pull/2696)

*This is alpha-quality code*

Currently supports all param options made available except SSL b/c I'm too lazy to test that at this time.

Likewise, this sorts the keys and fields to further hopefully make this the fastest writer currently out there (sorting is strongly recommended in the referenced PR).

If you fork this and make it better, I'll review, merge, increment version, and push an updated gem in a reasonable timeframe.

Default URI params are documented in lib/influxdb-lineprotocol-writer-ruby/core.rb in the class initializer. 

## Install

```shell
$ gem install influxdb-lineprotocol-writer
```

## Usage

```ruby
require 'influxdb-lineprotocol-writer'


client = InfluxDB::LineProtocolWriter::Core.new host: '<host/IP>', 
                                                  db: '<DB>', 
                                                user: '<USER>', 
                                                pass: '<PASS>'
client.debug = true # Enable debug Excon output
client.connect

client.add_metric 'test', {test: 'test', test2: 'test2', a: 'val'}, {value: 1.0}
sleep 0.1
client.add_metric 'test', {z: 'val2', test: 'test', test2: 'test2'}, {value: 2.0}
sleep 0.1
client.add_metric 'test', {z: 'val2', test: 'test', test2: 'test2'}, {value: 2.0}
client.add_metric 'test', {test: 'test', test2: 'test2'}, {value: 3.0}
sleep 0.1
client.add_metric 'test', nil, {value: 3.0}
client.add_metric 'test3', nil, {value: 3.0, test: 'string', deploy: 'v2.0'}
sleep 0.1
client.add_metric 'test3', nil, {value: 3.0, test: 'string', deploy: 'v2.1'}, 1434077536000

client.write
```
