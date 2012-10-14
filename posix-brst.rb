#!/usr/bin/env ruby

# POSIX Brazilian Summer Time 2012.9.13
# Copyright (c) 2012 Renato Silva
# GNU GPLv2 licensed

# This program prints BRST period for configuration of TZ environment variable
# in POSIX systems, using a timezone database to automatically determine the
# end week, which is variable in Brazil as of 2012.

require 'rubygems'
require 'tzinfo'

current = TZInfo::Timezone.get('America/Sao_Paulo').current_period
dst_end = (current.dst?? current.start_transition : current.end_transition).at.to_datetime
dst_end_week = (dst_end.day / 7) + (dst_end.day % 7 > 0? 1 : 0)
puts ",M10.3.0/0,M2.#{dst_end_week}.0/0"
