#!/usr/bin/env ruby
# Encoding: ISO-8859-1

##
##     Bazaar Grep Revision 2014.9.3
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
##         --from=WHERE      Branch or file where to search for the pattern
##                           (current directory by default).
##     -s, --case-sensitive  PATTERN is case-sensitive.
##         --no-color        Disable colors in output.
##

require_relative "easyoptions"
if not $arguments[0]
    puts "Pattern is required, see --help."
    exit
end

if not $options[:no_color] and ENV["TERM"] =~ /xterm/ and (system("test -t 1") or STDOUT.tty?)
    $red     = "\e[1;31m"
    $green   = "\e[0;32m"
    $cyan    = "\e[0;36m"
    $yellow  = "\e[0;33m"
    $normal  = "\e[0m"
end

def puts(text=nil, color=nil)
    case color
        when nil then    super(text)
        when $cyan then  super(text.gsub(/(#{$arguments[0]})/, "#{$cyan}\\1#{$normal}"))
        when $red then   super(text.gsub(/(#{$arguments[0]})/, "#{$red}\\1#{$normal}"))
        else             super("#{color}#{text}#{$normal}")
    end
end

pattern = $options[:case_sensitive]?
    /^\s*[+\-].*#{$arguments[0]}.*$/:
    /^\s*[+\-].*#{$arguments[0]}.*$/i

log = $options[:stdin]? STDIN : %x[bzr log --show-diff #{$options[:from]}]
last_rev, last_file = nil
first_match = true
output = []

log.each_line do |line|
    rev = line[/^\s*revno: (.*)/, 1]
    file = line[/^\s*=== .*'(.*)'/, 1]

    last_rev = rev if last_rev == nil or rev != nil
    last_file = file if last_file == nil or file != nil

    if line =~ pattern
        if last_rev != nil
            puts unless first_match
            puts "revision #{last_rev}", $green
            first_match = false
            last_rev = nil
        end
        if last_file != nil
            puts "\t#{last_file}", $yellow
            last_file = nil
        end
        line_color = line.start_with?("+")? $cyan : $red
        puts "\t\t#{line.gsub(/[\n\r]/, '')}", line_color
    end
end
puts
