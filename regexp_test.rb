#!/usr/bin/env ruby -w

line1 = "Cats are smarter than dogs";
line2 = "05x03   - The One With The Triplets The One Hundredth";

#if (/(\d{2})x(\d{2})(?:\s-\s)(.*)/ =~ line2)
#  puts $1, $2, $3
#end
str = '(\d\d)x(\d\d)\s*\-\s*(.*)'
m = Regexp.new(str).match(line2)
if m
  season = m[1]
  episode = m[2]
  episode_name = m[3]
  p(m)
else
  puts 'NO!'
end

new_file_name = "Friends.S"+season+"E"+episode+" "+episode_name
puts new_file_name

film = "06x24 - The One With The Proposal Part 1 & 2.avi"
m = /(?<season>\d\d)x(?<episode>\d\d).*\-\s*(?<name>.*)/.match(film)
puts m[:season]
puts m[:episode]
puts m[:name]

ddd = '(\d\d)x(\d\d).*\-\s*(.*)'
m = /#{ddd}/.match(film)
puts m[1]
puts m[2]
puts m[3]

fff = "(?<season>\\d\\d)x(?<episode>\\d\\d).*\\-\\s*(?<name>.*)"
puts "===#{fff}==="
m = /#{fff}/.match(film)
puts m[:season]
puts m[:episode]
puts m[:name]

rrr = '(?<season>\d\d)x(?<season2>\d\d).*\-\s*(?<season1>.*)'
puts rrr
m = Regexp.new(rrr).match(film)
puts m.inspect
n = m.names
a_season = n.select {|v| v =~ /^season/}.sort
puts a_season.inspect 
season_final = ""
a_season.each {|x| season_final += m[x] }
puts season_final


#m = /(.)(.)(\d+)(\d)/.match("THX1138: The Movie")
#puts m.to_a               #=> ["HX1138", "H", "X", "113", "8"]
#puts m.values_at(0, 2, -2)   #=> ["HX1138", "X", "113"]
