#!/usr/bin/env ruby

# TZ Configuration for Brazil 2012.12.29
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This program prints configuration of TZ environment variable for BRT
# timezone. BRT is the main timezone in Brazil, and corresponds to the
# official time at Brasília. This program uses a timezone database to
# automatically determine the end week for summer time period, which
# is variable in Brazil as of 2012. Despite being created for use with
# MinGW MSYS, this program is suitable for POSIX systems in general.

require 'rubygems'
require 'tzinfo'

current = TZInfo::Timezone.get('America/Sao_Paulo').current_period
dst_end = (current.dst?? current.end_transition : current.start_transition).at.to_datetime
dst_end_week = (dst_end.day / 7) + (dst_end.day % 7 > 0? 1 : 0)
puts "export TZ=\"BRT+3BRST,M10.3.0/0,M2.#{dst_end_week}.0/0\""
