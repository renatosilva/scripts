#!/usr/bin/env ruby

# CSV Transformation 2012.12.20
# Copyright (c) 2009, 2012 Renato Silva
# GNU GPLv2 licensed

if not ARGV[2]
    puts "Usage: #{File.basename($0)} <csv file> <output file> <template file>"
    exit
end

csv = File.open(ARGV[0], 'r')
out = File.open(ARGV[2], 'rb').read
row_pattern = /(.*<csv:row>(.*)<\/csv:row>)/
row_template = out[row_pattern, 1]

csv.each_line do |line|    
    row = out[row_pattern, 2]
    cols = line.gsub(/\n/, '').split(";")
    cols.each_with_index { |col, ix| row.gsub!(/\$#{ix + 1}/, col) }
    row.gsub!(/\$\d+/, '')
    row << "\n#{row_template}" unless csv.eof?
    out.sub!(row_template, row)
end

File.open(ARGV[1], 'wb').write out
