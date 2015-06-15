#!/bin/bash

while true; do 
  bundle exec ./sensu-metric-check.rb -h $1 -c 1 |\
  bundle exec ./sensu_event_generator.rb |\
  bundle exec ./influxdb_event_handler.rb
  sleep 1
done
