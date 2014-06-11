#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# Grep Revision 2014.6.11
# Copyright (C) 2010, 2012-2014 Renato Silva
# GNU GPLv2 licensed

if not ARGV[0]
    puts "Usage: #{File.basename($0)} <pattern>"
    exit
end

last_rev, last_file = nil
output = []

STDIN.each do |line|
    rev = line[/^\s*revno: (.*)/, 1]
    file = line[/^\s*=== .*'(.*)'/, 1]

    last_rev = rev if last_rev == nil or rev != nil
    last_file = file if last_file == nil or file != nil

    if line =~ /^\s*[+\-].*#{ARGV[0]}.*$/i
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
