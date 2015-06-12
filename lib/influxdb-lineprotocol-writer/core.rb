require 'excon'

module InfluxDB
  module LineProtocolWriter
    module Util
      def build_metric(measurement, tags, fields, precision='ms', timestamp=nil)
        raise OptionError, 'measurement does not implement to_s' unless measurement.respond_to? :to_s
        raise OptionError, 'fields does not implement to_h' unless fields.respond_to? :to_h
        raise OptionError, 'precision does not implement to_s' unless precision.respond_to? :to_s
        timestamp = get_now_timestamp(precision.to_s) unless timestamp
        working = measurement.to_s
        if tags.respond_to?(:to_h) && !tags.to_h.empty?
          working += ',' + tags.sort.map{|k,v|"#{k.to_s}=#{v.to_s}"}.join(",")
        end
        working += ' '
        working += fields.sort.map{|k,v|"#{k.to_s}=#{if v.is_a?(String);'"'+v+'"';else;v;end}"}.join(",")
        working += " #{timestamp}"
      end
      def check_precision(val)
        if %[n u ms s m h].include?(val.to_s)
          true
        else
          false
        end
      end
      def get_now_timestamp precision
        check_precision precision
        case precision
        when 'n'
          raise NotSupportedError, 'Nanosecond resolution not currently supported.  Pass timestamp in manually'
        when 'u'
          raise NotSupportedError, 'Microsecond resolution not currently supported.  Pass timestamp in manually'
        when 'ms'
          ( Time.now.to_f * 1000 ).to_i
        when 's'
          Time.now.to_i
        when 'm'
          ( Time.now.to_i / 60 ).to_i
        when 'h'
          ( Time.now.to_i / 3600 ).to_i
        end
      end
    end
    class Core
      include Util

      attr_reader :host, :port, :user, :pass, :ssl, :db, :precision, :consistency, :retentionPolicy, :debug

      def initialize(opts={})
        # set the defaults
        opts = {host: 'localhost',
                port: '8086',
                user: 'root',
                pass: 'root',
                ssl: false,
                db: 'influxdb',
                precision: 'ms',
                consistency: 'one',
                retentionPolicy: 'default',
                debug: false}.merge(opts)
        self.host = opts[:host]
        self.port = opts[:port]
        self.user = opts[:user]
        self.pass = opts[:pass]
        self.ssl  = opts[:ssl]
        self.db   = opts[:db]
        self.precision   = opts[:precision]
        self.consistency = opts[:consistency]
        self.retentionPolicy = opts[:retentionPolicy]
        self.debug = opts[:debug]
        @metrics = Array.new
      end

      def connect
        @conn = Excon.new(get_uri, debug: debug)
      end

      def add_metric(*args)
        @metrics << build_metric(*args)
      end

      def write
        @conn.request( expects: [204],
                       method:  :post,
                       headers: get_headers,
                       query:   get_query_hash,
                       body:    metrics
                     )
      rescue Excon::Errors::InternalServerError => e
        puts "Internal Server Error: #{e.response.body}"
        exit 1
      rescue Excon::Errors::NotFound => e
        puts "Not Found: #{e.response.body}"
        exit 1
      rescue Excon::Errors::Timeout
        puts "Connect Timout: #{host}:#{port} unreachable"
        exit 1
      rescue Excon::Errors::Unauthorized
        puts "Unauthorized: #{user}/#{pass} not allowed to write to #{db}"
        exit 1
      end

      def metrics
        if @metrics.respond_to? :to_a
          @metrics.join("\n")
        else
          @metrics
        end
      end

      def metrics= val
        if val.respond_to?(:to_a) or val.respond_to?(:to_s)
          @metrics = val
        else
          raise OptionError, 'Metrics must implement #to_a or #to_s'
        end
      end

      def host= val
        @host = val.to_s
      end

      def port= val
        @port = val.to_s
      end

      def user= val
        @user = val.to_s
      end

      def pass= val
        @pass = val.to_s
      end

      def ssl=  val
        # @ssl = !!val
        if !!val == true
          raise NotSupportedError, 'Error: SSL is not currently supported!'
          exit 1
        end
      end

      def db=   val
        @db = val.to_s
      end

      def retentionPolicy= val
        @retentionPolicy = val
      end


      def precision= val
        if check_precision val
          @precision = val.to_s
        else
          raise OptionError, 'Precision must be one of (n, u, ms, s, m, h)'
        end
      end

      def consistency= val
        if %[one all any quorum].include?(val.to_s)
          @consistency = val
        else
          raise OptionError, 'Consistency must be one of (one, all, any, quorum)'
        end
      end

      def debug= val
        @debug = !!val
      end

      private

      def get_query_hash
        { db:          db,
          rp:          retentionPolicy,
          precision:   precision,
          consistency: consistency,
          u:           user,
          p:           pass
        }
      end

      def get_uri
        if ssl
          uri = "https://"
        else
          uri = "http://"
        end
        "#{uri}#{host}:#{port}/write"
      end

      def get_headers
        { 'Content-Type' => 'plain/text' }
      end
    end
  end
end
