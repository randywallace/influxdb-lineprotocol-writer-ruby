require 'influxdb-lineprotocol-writer'


client = InfluxDB::LineProtocolWriter::Core.new host: '10.0.1.159', db: 'graphite'
client.debug = true
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
client.add_metric 'test3', nil, {value: 3.0, test: 'string', deploy: 'v2.1'}

client.write
