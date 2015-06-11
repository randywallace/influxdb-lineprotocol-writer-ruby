require 'influxdb-lineprotocol-writer'


client = InfluxDB::LineProtocolWriter::Core.new host: '10.0.1.159', db: 'graphite', user: 'null'
client.connect
client.write
