#!/usr/bin/env ruby

require 'influxdb-lineprotocol-writer'
require 'benchmark'


Benchmark.bm(7) do |x|
  client = InfluxDB::LineProtocolWriter::Core.new host: '10.0.1.159', db: 'graphite', user: 'admin', pass: 'admin'
  client.debug = true
  x.report(__LINE__) { client.connect }
  
  x.report(__LINE__) { client.add_metric 'test', {test: 'test', test2: 'test2', a: 'val'}, {value: 1.0}, 'ms'}
  x.report(__LINE__) { client.add_metric 'test', {z: 'val2', test: 'test', test2: 'test2'}, {value: 2.0}}
  x.report(__LINE__) { client.add_metric 'test', {z: 'val2', test: 'test', test2: 'test2'}, {value: 2.0}}
  x.report(__LINE__) { client.add_metric 'test', {test: 'test', test2: 'test2'}, {value: 3.0}}
  x.report(__LINE__) { client.add_metric 'test', nil, {value: 3.0}}
  x.report(__LINE__) { client.add_metric 'test3', nil, {value: 3.0, test: 'string', deploy: 'v2.0'}}
  x.report(__LINE__) { client.add_metric 'test3', nil, {value: 3.0, test: 'string', deploy: 'v2.1'}, 'ms', 1434077536000}
  
#  x.report(__LINE__) { puts client.metrics}
  
  x.report(__LINE__) { client.write}
end
