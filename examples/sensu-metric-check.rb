#!/usr/bin/env ruby

require 'influxdb-lineprotocol-writer/sensu-metric-check'
require 'net/ping'

class PingMetric < InfluxDB::LineProtocolWriter::Metric::CLI
  option :host,
         short: '-h host',
         default: 'localhost'

  option :timeout,
         short: '-T timeout',
         proc: proc(&:to_i),
         default: 5

  option :count,
         short: '-c count',
         description: 'The number of ping requests',
         proc: proc(&:to_i),
         default: 1

  option :interval,
         short: '-i interval',
         description: 'The number of seconds to wait between ping requests',
         proc: proc(&:to_f),
         default: 1

  option :'measurement-name',
         short: '-m measurement_name',
         description: 'An alternate name for the metric',
         proc: proc(&:to_s),
         default: 'ping'

  def run
    result_arr = []
    pt = Net::Ping::External.new(config[:host], nil, config[:timeout])
    config[:count].times do |i|
      sleep(config[:interval]) unless i == 0
      unless pt.ping?
        warning "Failed to ping #{config[:host]}"
      else
        result_arr << pt.duration
      end
    end
    duration = result_arr.inject{ |sum, el| sum + el }.to_f / result_arr.size
    begin
      output measurement: config[:'measurement-name'],
             tags: { host: config[:host] },
             fields: { value: duration }
    rescue InfluxDB::LineProtocolWriter::OptionError => e
      warning e.message
    rescue Exception => e
      critical e.message
    end
    ok "Ping check of #{config[:host]} Successful"
  end
end
