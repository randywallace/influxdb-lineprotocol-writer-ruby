require 'influxdb-lineprotocol-writer'
require 'sensu-handler'
require 'json'

module InfluxDB
  module LineProtocolWriter
    class Metric
      class Handler < Sensu::Handler
        include ::InfluxDB::LineProtocolWriter::Util

        def split_metrics_from_output
          metrics = []
          output = ''
          @event['check']['output'].each_line do |line|
            begin
              metrics << JSON.parse(line.chomp).to_h
            rescue
              output += line.chomp + ' '
            end
          end
          return metrics, output
        end

        def write_metrics(metrics, settings, debug=false)
          metrics.chunk{ |i| i['precision'] }.each do |precision_group|
            settings[:precision] = precision_group[0]
            settings = Hash[settings.map{ |k,v| [k.to_sym, v] } ]
            settings[:debug] = debug
            client = Core.new settings
            client.connect
            precision_group[1].each do |metric|
              yield metric if block_given?
              client.add_metric metric['measurement'],
                                metric['tags'],
                                metric['fields'],
                                metric['precision'],
                                metric['timestamp']
            end
            client.write
          end
        end

      end
    end
  end
end
