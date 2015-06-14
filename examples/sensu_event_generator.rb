#!/usr/bin/env ruby

require 'json'

check_output = ARGF.read

event_json_base = JSON.parse(File.read('sensu_event.json'))
event_json_base["output"] = check_output.to_s
event_json_base["command"] = "test.rb -c 1"

puts JSON.pretty_generate(event_json_base)

