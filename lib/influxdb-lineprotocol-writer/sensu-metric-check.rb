require 'influxdb-lineprotocol-writer'
require 'sensu-plugin/cli'
require 'json'

module InfluxDB
  module LineProtocolWriter
    class Metric
      class CLI < Sensu::Plugin::CLI
        include InfluxDB::LineProtocolWriter::Util
        def output opts=''
          if opts.respond_to? :to_h

            opts[:measurement] ||= File.basename($0, ".*")
            opts[:tags]        ||= {}
            opts[:precision]   ||= 'ms'
            opts[:timestamp]   ||= get_now_timestamp(opts[:precision])

            if !opts.key?(:fields) || !opts[:fields].respond_to?(:to_h) || opts[:fields].to_h.keys.length == 0
              raise OptionError, "At least one field is required.  For example: { fields: { key: value } }"
            end

            puts opts.to_json
          else
            puts opts.to_s
          end
        end
      end
    end
  end
end
