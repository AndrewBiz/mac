#!/usr/bin/env ruby -w
target_dir = ARGV[0]||"mov_"+rand(1000).to_s
fmask = ARGV[1]||"*.mov"
astream = ARGV[2]||1
lang = ARGV[3]||"eng"

script_name = "2_cnv_movie.sh"

outdir = "/Volumes/WD/mov/2_converted/"+target_dir
if not File.exists?(outdir)
  Dir.mkdir(outdir)
end

puts "MASK: #{fmask}, outdir: #{outdir}, script: #{script_name}, lang: #{lang}"

File.open(script_name, "w+") do |f|
  Dir.glob(fmask).each do |movie|
    f.puts "movcnv_1v1a1s.sh \"#{movie}\" \"#{outdir}\" #{astream} \"#{lang}\""
  end
end

#making the script executable
File.chmod(0775, script_name)