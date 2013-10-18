#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# Wi-Fi Reconnections 2013.10.17
# Copyright (c) 2013 Renato Silva
# GNU GPLv2 licensed

if [nil, "-h", "--help"].include? ARGV[0]
    puts "Usage: #{File.basename($0)} <log file>"
    puts "Log entries should consist of date, time, SSID and uptime, separated by space."
    exit
end

log = File.open(ARGV[0].encode(ARGV[0].encoding, 'ISO-8859-1'), "r")
networks = {}

log.readlines.each do |line|
    date, time, network, uptime = line.split
    networks[network] = {} if networks[network] == nil
    networks[network][date] = { :uptime => 0, :reconnections => 0 } if networks[network][date] == nil

    networks[network][date][:uptime] += uptime.to_f
    networks[network][date][:reconnections] += 1
end

csv = File.open(log.path.sub(/log$/, "csv"), "w")
csv.puts("Network;Date;Reconnections/hour; Average uptime")

networks.keys.each do |network|
    networks[network].keys.each do |date|
        info = networks[network][date]
        average_uptime = info[:uptime] / info[:reconnections]
        hourly_reconnections = info[:reconnections] / (info[:uptime] / 60 / 60)
        csv.puts "#{network};#{date};#{hourly_reconnections.round};#{average_uptime.round}"
    end
end
