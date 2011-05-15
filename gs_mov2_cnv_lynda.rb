#!/usr/bin/ruby
fmask = ARGV[0]||"*.mov"
outdir = ARGV[1]||"/Volumes/WD/mov/2_converted"
script_name = "2-convert_movie.sh"

puts "MASK: #{fmask}, outdir: #{outdir}, script: #{script_name}"

File.open(script_name, "w+") do |f|
  Dir.glob(fmask).each do |movie|
    f.puts "movcnv_lynda.sh \"#{movie}\" \"#{outdir}\""
  end
end

#making the script executable
File.chmod(0775, script_name)