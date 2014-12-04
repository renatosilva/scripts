#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# Wi-Fi Reconnections 2014.12.3
# Copyright (c) 2013, 2014 Renato Silva
# GNU GPLv2 licensed

if [nil, '-h', '--help'].include? ARGV[0]
    puts "Usage: #{File.basename($0)} <log file>"
    puts 'Log entries should consist of date, time, SSID and uptime, separated by space.'
    exit
end

log = File.open(ARGV[0].encode(ARGV[0].encoding, 'ISO-8859-1'), 'r')
networks = {}

log.readlines.each do |line|
    date, time, network, uptime = line.split
    networks[network] = {} if networks[network] == nil
    networks[network][date] = { :uptime => 0, :reconnections => 0 } if networks[network][date] == nil

    networks[network][date][:uptime] += uptime.to_f
    networks[network][date][:reconnections] += 1
end

csv = File.open(log.path.sub(/log$/, 'csv'), 'w')
csv.puts('Network;Date;Reconnections/hour; Average uptime')

networks.keys.each do |network|
    networks[network].keys.each do |date|
        info = networks[network][date]
        average_uptime = info[:uptime] / info[:reconnections]
        uptime_hours = info[:uptime] / 60 / 60
        uptime_hours = 1 if uptime_hours < 1
        hourly_reconnections = info[:reconnections] / uptime_hours
        csv.puts "#{network};#{date};#{hourly_reconnections.round};#{average_uptime.round}"
    end
end
