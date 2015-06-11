module InfluxDB
  module LineProtocolWriter
    class OptionError < StandardError
    end

    class UnreachableHostError < StandardError
    end

    class FailedLoginError < StandardError
    end

  end
end
