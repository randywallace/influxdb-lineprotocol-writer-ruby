require 'sensu-plugin/cli'

module InfluxDB
  module LineProtocolWriter
    class Metric
      class CLI
        def output(obj=nil)
          if obj.respond_to? :to_s
            puts obj.to_s
          else
            warning 'Only objects that implement #to_s are supported'
          end
        end
      end
    end
  end
end
