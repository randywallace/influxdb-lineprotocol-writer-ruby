require 'excon'

module InfluxDB
  module LineProtocolWriter
    class Core
      attr_reader :host, :port, :user, :pass, :ssl, :db, :precision, :consistency, :retentionPolicy
      def initialize(opts={})
        # set the defaults
        opts      = {host: 'localhost', port: '8086', user: 'root', pass: 'root', ssl: false, db: 'influxdb', precision: 'ms', consistency: 'one', retentionPolicy: 'default'}.merge(opts)
        self.host = opts[:host]
        self.port = opts[:port]
        self.user = opts[:user]
        self.pass = opts[:pass]
        self.ssl  = opts[:ssl]
        self.db   = opts[:db]
        self.precision   = opts[:precision]
        self.consistency = opts[:consistency]
      end

      def connect
        @conn = Excon.new(get_uri, debug: true)
      end

      def write
        response = @conn.request( expects: [204],
                                  method:  :post,
                                  headers: get_headers,
                                  query:   get_query_hash,
                                  body:    "test,test=test2 value=1.0 #{(Time.now.to_f * 1000).to_i}" )
        puts response.inspect
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
        @ssl = !!val
      end

      def db=   val
        @db = val.to_s
      end

      def retentionPolicy= val
        @retentionPolicy = val
      end

      def precision= val
        if %[n u ms s m h].include?(val.to_s)
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
        if self.ssl
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
