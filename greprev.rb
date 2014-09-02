#!/usr/bin/env ruby
# Encoding: ISO-8859-1

##
##     Bazaar Grep Revision 2014.9.2
##     Copyright (C) 2010, 2012-2014 Renato Silva
##     GNU GPLv2 licensed
##
## This script searches for a given pattern in the commit history of a Bazaar
## branch. This can be used to find what revisions have introduced, removed or
## changed a given piece of code.
##
## Usage: @script.name [options] PATTERN
##
##     -i, --stdin           Read commit log from standard input. The expected
##                           format for the log is that of bzr log --show-diff.
##         --from=WHERE      Branch location where to search for the pattern
##                           (current directory by default).
##     -s, --case-sensitive  PATTERN is case-sensitive.
##

require_relative "easyoptions"
if not $arguments[0]
    puts "Pattern is required, see --help."
    exit
end

pattern = $options[:case_sensitive]?
    /^\s*[+\-].*#{$arguments[0]}.*$/:
    /^\s*[+\-].*#{$arguments[0]}.*$/i

log = $options[:stdin]? STDIN : %x[bzr log --show-diff #{$options[:from]}]
last_rev, last_file = nil
output = []

log.each_line do |line|
    rev = line[/^\s*revno: (.*)/, 1]
    file = line[/^\s*=== .*'(.*)'/, 1]

    last_rev = rev if last_rev == nil or rev != nil
    last_file = file if last_file == nil or file != nil

    if line =~ pattern
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
