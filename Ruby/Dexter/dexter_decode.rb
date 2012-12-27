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
# dexter_decode.rb by Josh Grunzweig 12-27-2012
#
# =Synopsis
#
# This is a simple Ruby script that is designed to take the POST data sent by
# the Dexter malware, and decode the data present using the Base64 encoded
# key that is supplied. More information about how this data is decoded, and
# what values are present can be found here: 
# http://blog.spiderlabs.com/2012/12/the-dexter-malware-getting-your-hands-dirty.html
#
# This script was tested against cae3cdaaa1ec224843e1c3efb78505b2e0781d70502bedff5715dc0e9b561785,
# however, it may work against other variants as well. 
#
# Example: ruby dexter_decode.rb 'page=AwICB1VWVwRMUVVYVUxVUwAHTABWAFZMUVJTUlECWAVVVlVU&val=ZnJ0a2o='
# KEY: frtkj
# ["page", "bccf476e-0494-42af-a7a7-03230c9d4745"]
#


require 'base64'

class String
  # Taken from Eric Monti's excellent Ruby Black Bag Ruby gem. More information
  # about this gem can be found here: https://github.com/emonti/rbkb
  #
  # xor against a key. key will be repeated or truncated to self.size.
  def xor(k)
    i=0
    self.bytes.map do |b|
      x = k.getbyte(i) || k.getbyte(i=0)
      i+=1 
      (b ^ x).chr
    end.join
  end
end

string = ARGV.shift
unless string
  puts "Usage: ruby dexter_decode.rb <POST_DATA>"
  exit
end

key = ""
params = string.split("&")
params.each do |param|
  param.scan(/^(\w+)=(\S+)$/) do |name, str|
    if name == "val"
      key = Base64.decode64(str)
    end
  end
end

puts "KEY: #{key}"

params = string.split("&")
params.each do |param|
  param.scan(/^(\w+)=(\S+)$/) do |name, str|
    b64_decoded = Base64.decode64(str)
    res_var = ""
    b64_decoded.each_char do |char|
      var = char
      key.each_char do |key_char|
        var = var.xor(key_char)
      end
      res_var << var
    end
    p [name, res_var] unless name == "val"
  end
end

