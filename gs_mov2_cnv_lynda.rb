#!/usr/bin/ruby
target_dir = ARGV[0]||"mov_"+rand(1000).to_s
fmask = ARGV[1]||"*.mov"
script_name = "2-convert_movie.sh"

outdir = "/Volumes/WD/mov/2_converted/"+target_dir
if not File.exists?(outdir)
  Dir.mkdir(outdir)
end

puts "MASK: #{fmask}, outdir: #{outdir}, script: #{script_name}"

File.open(script_name, "w+") do |f|
  Dir.glob(fmask).each do |movie|
    f.puts "movcnv_lynda.sh \"#{movie}\" \"#{outdir}\""
  end
end

#making the script executable
File.chmod(0775, script_name)