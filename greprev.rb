#!/usr/bin/env ruby

# Version 2012.1.17
# License: GNU GPLv2
# Copyright: Renato Silva

if not ARGV[0]
    puts "Usage: #{File.basename($0)} <pattern>"
    exit
end

last_rev, last_file = nil
output = []

STDIN.each do |line|
    rev = line[/^revno: (.*)/, 1]
    file = line[/^=== .*'(.*)'/, 1]

    last_rev = rev if last_rev == nil or rev != nil
    last_file = file if last_file == nil or file != nil

    if line =~ /^[+\-].*#{ARGV[0]}.*$/i
        if last_rev != nil
            output << "revision #{last_rev}"
            last_rev = nil
        end
        if last_file != nil
            output << "\t#{last_file}"
            last_file = nil
        end
        output << "\t\t#{line.gsub(/[\n\r]/, '')}"
    end
end

puts output
