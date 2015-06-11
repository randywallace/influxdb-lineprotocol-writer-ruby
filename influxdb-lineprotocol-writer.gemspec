lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'influxdb-lineprotocol-writer/version'

Gem::Specification.new do |s|
  s.name        = 'influxdb-lineprotocol-writer'
  s.version     = InfluxDB::LineProtocolWriter::VERSION
  s.licenses    = ['MIT']
  s.summary     = "This is a library for the sole purpose of writing one or more datapoints to InfluxDB via the new LineProtocol (https://github.com/influxdb/influxdb/pull/2696)"
  s.description = <<EOF
EOF
  s.authors     = ["Randy D. Wallace Jr."]
  s.email       = 'randy+influxdb-lineprotocol-writer@randywallace.com'

  s.files         = `git ls-files -z`.split("\x0")
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.required_ruby_version = '>= 2.0.0'
  s.homepage    = 'https://github.com/randywallace/influxdb-lineprotocol-writer-ruby'

  s.add_runtime_dependency 'excon', '>= 0.45.3'
  #s.add_development_dependency
end
