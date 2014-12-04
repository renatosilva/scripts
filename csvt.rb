#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# CSV Transformation 2014.12.4
# Copyright (c) 2009, 2012-2014 Renato Silva
# GNU GPLv2 licensed

unless ARGV[2]
    puts "Usage: #{File.basename($PROGRAM_NAME)} <csv file> <output file> <template file> [delimiters]"
    exit
end

csv = File.open(ARGV[0], 'r')
out = File.open(ARGV[2], 'rb').read
row_pattern = /(([ \t]*)<csv:row(\s*delimiters=['\"]([^'\"]*)['\"])*>(.*)<\/csv:row>)/
row_template = out[row_pattern, 1]
delimiters = (ARGV[3] || out[row_pattern, 4])
delimiters = ';' if delimiters.nil?

csv.each_line do |line|
    row = out[row_pattern, 2] + out[row_pattern, 5]
    cols = line.gsub(/\n/, '').split(/\s*[#{delimiters}]\s*/)
    cols.each_with_index { |col, ix| row.gsub!(/\$#{ix + 1}/, col) }
    row.gsub!(/\$\d+/, '')
    row << "\n#{row_template}" unless csv.eof?
    out.sub!(row_template, row)
end

File.open(ARGV[1], 'wb').write out
