#!/usr/bin/env ruby

require 'influxdb-lineprotocol-writer/sensu-metric-handler'

class InfluxDBHandler < ::InfluxDB::LineProtocolWriter::Metric::Handler

  def filter; end

  def handle
    metrics, output = split_metrics_from_output

    begin
      settings = settings['influxdb']
    rescue
      settings = {}
    end
    settings['host'] ||= '10.0.1.159'
    settings['user'] ||= 'admin'
    settings['pass'] ||= 'admin'
    settings['db']   ||= 'graphite'

    hostname, instance_id = @event['client']['name'].split('--')
    write_metrics metrics, settings do |metric|
      metric['tags']['source'] = hostname
      metric['tags']['instance_id'] = instance_id unless instance_id.nil?
    end

    puts output

  end
end

