# Copyright
# =========
# Copyright (C) 2013 Trustwave Holdings, Inc.
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
# alina.rb by Josh Grunzweig 10-04-2013
#
# =Synopsis
#
# This is a simple Ruby script that is designed to decode the network 
# traffic sent by the Alina POS malware. This script is designed to work on
# versions 5.2-6.0. It may work on newer versions as well, however, it has
# not been tested against these. 
#
# Example: ruby alina.rb -f file_containing_traffic.txt
#
# Example: ruby alina.rb -d "traffic_in_hex"
#
# Full Example:
# JGrunzweig> ruby alina.rb -d a9afebc6c3c4cb8adc9f8499aaaaaaaaaaaacf929b92939c989b8389dfdacecbdecfaaaaeeefe6e6f2feaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa78aaaaaac601038d0151505f041307530c1014555759515638255708140b5a1304040c1544555704515064255708140f5b1307530c1144555753515639255709140d5d1305550c1417555103515731255609140a081307550c141155540052
# Header Information
# ------------------
# Static Value: "\x03\x05"
# Alina Version: "Alina v5.3"
# Volume Serial: "e818962"
# Random Bytes: "1)"
# Command: "#update"
# Hostname: "DELLXT"
# Unknown: "\xD2\x00\x00\x00"
# Unknown: "l\xAB\xA9'"
# 
# Payload Decoded
# ---------------
# diag=[:88 <ea>] {[!29!]}{[!1!]}
# &
#

# Extend functions taken from Eric Monti's rbkb
# https://github.com/emonti/rbkb
class String
	def unhexify(d=/\s*/)
		self.strip.gsub(/([A-Fa-f0-9]{1,2})#{d}?/) { $1.hex.chr }
	end

	def xor(k)
		i=0
		self.bytes.map do |b|
	  		x = k.getbyte(i) || k.getbyte(i=0)
	  		i+=1
			(b ^ x).chr
		end.join
	end
end

def usage
	puts "Usage: ruby #{__FILE__} (-f|-d) (file|hex)"
	exit 1
end

def decrypt(data)
	decoded = data.xor("\xAA")
	start = data[76..-1]
	puts "Header Information"
	puts "------------------"
	puts "Static Value: #{decoded[0..1].inspect}"
	puts "Alina Version: #{decoded[2..16].gsub("\x00",'').inspect}"
	puts "Volume Serial: #{decoded[17..24].gsub("\x00",'').inspect}"
	puts "Random Bytes: #{decoded[25..26].inspect}"
	puts "Command: #{decoded[27..35].gsub("\x00",'').inspect}"
	puts "Hostname: #{decoded[36..67].gsub("\x00",'').inspect}"
	puts "Unknown: #{decoded[68..71].inspect}"
	puts "Unknown: #{decoded[72..75].inspect}"
	puts

	c = 0
	dataStr = ""
	start.each_char do |x| 
		dataStr << x.xor(decoded[(c % 18)+18])
		c = c+1
	end
	puts "Payload Decoded"
	puts "---------------"
	puts dataStr.gsub(/\%([0-9a-f]{2})/){ $1.unhexify }
end

usage unless (opt = ARGV.shift)
usage unless (opt.downcase=='-f' or opt.downcase=='-d')
	
if (opt == '-f')
	usage unless (file = ARGV.shift)
	f = File.read(file)
	decrypt(f)
elsif (opt == '-d')
	usage unless (data = ARGV.shift)
	decrypt(data.unhexify)
end
