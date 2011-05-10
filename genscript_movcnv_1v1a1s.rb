#!/usr/bin/ruby
fmask = ARGV[0]||"*.avi"
astream = ARGV[1]||1
lang = ARGV[2]||"eng"  
script_name = "convert4iphone.sh"

puts "MASK: #{fmask}, script: #{script_name}"

File.open(script_name, "w+") do |f|
  Dir.glob(fmask).each do |movie|
    f.puts "movcnv_1v1a1s.sh \"#{movie}\" #{astream} #{lang}"
  end
end

#making the script executable
File.chmod(0775, script_name)