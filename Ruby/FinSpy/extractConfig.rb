# Copyright
# =========
# Copyright (C) 2012 Trustwave Holdings, Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>
#
#
# extractConfig.rb by Josh Grunzweig 9-30-2012
#
# =Synopsis
#
# This is a simple Ruby script that is designed to pull out, or extract, the 
# configuration from an Android FinSpy sample.
#
# The configuration file is piped to STDOUT, but it is of course trivial to 
# have it sent to a file instead.
#
# Example: ruby extractConfig.rb finSpy.apk > config.dat
#
# Once the configuration has been extracted, it can be manipulated in a hex
# editor, or parsed using the accompanying parseConfig.rb Ruby script.
#

require 'base64'

file = ARGV.shift
unless file
  puts "Usage: extractConfig.rb <finspy_sample>"
  exit
end

f = File.new(file, 'rb')
fd = f.read
str = fd.scan(/PK\x01\x02.{32}(.{6})(.{4}assets\/Configurations\/dumms\d+\.dat)/m).collect{|x| x[0].to_s}.join
str.gsub!("\u0000",'')
puts Base64.decode64(str)
f.close
