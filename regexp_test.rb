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



#m = /(?<foo>a+)b/.match("ccaaab")
#puts m.inspect          #=> #<MatchData "aaab" foo:"aaa">
#puts m["foo"]   #=> "aaa"
#puts m[:foo]    #=> "aaa"

#m = /(.)(.)(\d+)(\d)/.match("THX1138: The Movie")
#puts m.to_a               #=> ["HX1138", "H", "X", "113", "8"]
#puts m.values_at(0, 2, -2)   #=> ["HX1138", "X", "113"]
