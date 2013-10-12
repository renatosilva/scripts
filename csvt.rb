#!/usr/bin/env ruby
# Encoding: ISO-8859-1

# CSV Transformation 2013.10.11
# Copyright (c) 2009, 2012, 2013 Renato Silva
# GNU GPLv2 licensed

if not ARGV[2]
    puts "Usage: #{File.basename($0)} <csv file> <output file> <template file> [delimiters]"
    exit
end

csv = File.open(ARGV[0], 'r')
out = File.open(ARGV[2], 'rb').read
row_pattern = /(.*<csv:row(\s*delimiters=['\"]([^'\"]*)['\"])*>(.*)<\/csv:row>)/
row_template = out[row_pattern, 1]
delimiters = (ARGV[3] or out[row_pattern, 3])
delimiters = ";" if delimiters.nil?

csv.each_line do |line|    
    row = out[row_pattern, 4]
    cols = line.gsub(/\n/, '').split(/[#{delimiters}]/)
    cols.each_with_index { |col, ix| row.gsub!(/\$#{ix + 1}/, col) }
    row.gsub!(/\$\d+/, '')
    row << "\n#{row_template}" unless csv.eof?
    out.sub!(row_template, row)
end

File.open(ARGV[1], 'wb').write out
