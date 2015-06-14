#!/usr/bin/env ruby

require 'influxdb-lineprotocol-writer'
require 'sensu-handler'
require 'json'

module Sensu
  module InfluxDB
    class Handler < Sensu::Handler
      include ::InfluxDB::LineProtocolWriter::Util

      def filter; end

      def handle
        @metrics = []
        @event['output'].each_line do |line|
          begin
            @metrics << JSON.parse(line.chomp).to_h
          rescue
            puts "'#{line.chomp}' cannot be parsed"
          end
        end

        begin
          settings = settings['influxdb']
        rescue
          settings = {}
        end
        settings['host'] = '10.0.1.159'
        settings['user'] = 'admin'
        settings['pass'] = 'admin'
        settings['db'] = 'graphite'

        @metrics.chunk{|i|i["precision"]}.each do |precision_group|
          settings[:precision] = precision_group[0]
          settings = Hash[settings.map{|k,v|[k.to_sym,v]}]
          client = ::InfluxDB::LineProtocolWriter::Core.new settings
          #client.debug = true
          client.connect
          precision_group[1].each do |metric|
            client.add_metric metric['measurement'], metric['tags'], metric['fields'], metric['precision'], metric['timestamp']
          end
          client.write

        end

      end
    end
  end
end
