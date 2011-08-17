#!/usr/bin/env ruby -w
require "yaml"

# read input args
yaml_name = ARGV[0]||"gs_foto_process_options.yaml"
dir_to_process = ARGV[1]||Dir.pwd
Dir.chdir(dir_to_process)

# read script_options
if File.file?(yaml_name)
  begin
    parsed_options = YAML.load_file(yaml_name)
    input_parameter = parsed_options[:input_parameter]
    #p(input_parameter)
    output_parameter = parsed_options[:output_parameter]
    #p(output_parameter)
  rescue ArgumentError => e
    puts "Could not parse YAML #{yaml_name}: #{e.message}"
    exit
  end
else
  puts "File #{yaml_name} is not a file ..."
  exit
end

# init
foto_ext = input_parameter[:foto_ext]
fmask = foto_ext.collect {|x| File.join("**", "*."+x)}

script_name = input_parameter[:script_name]||"1_foto_process.rb" 

foto_author_aka = output_parameter[:foto_author_aka]||"ANB"
foto_author = output_parameter[:foto_author]||"Andrey Bizyaev (c)"

output_path = input_parameter[:output_path]||"." 
Dir.mkdir(output_path) unless File.exists?(output_path)

puts "DIR: #{dir_to_process} MASK: #{fmask.inspect}, script: #{script_name}"
# gen script
count = 0
File.open(script_name, "w+") do |f|
  f.puts "#!/bin/bash"
#  Dir.foreach_recursive(dir_to_process, fmask) do |dir, file|
  f.puts "echo \"***RENAMING FILES***\""
  Dir.glob(fmask) do |file|
    print "*"
    count += 1
    f.puts "echo \"*** #{count} **\""
    full_file_name = File.realpath(file)
    file_ext = File.extname(file)
    file_name = File.basename(file, file_ext)
    
    #change flags
    f.puts "chflags nouchg #{full_file_name}"
    f.puts "chmod go=u-w #{full_file_name}" 
    
    if (/^(\d{8}-\d{4}-\w{3}_)(.*)/ =~ file_name) #check if file already renamed to YYYYMMDD-hhss-AUT format
      origin_file_name = $2
      #move - do not change name origin
      new_file_name = File.join(output_path, file_name+file_ext)
      f.puts "mv #{full_file_name} #{new_file_name}"       
    elsif (/^(\d{8}-\d{4}_)(.*)/ =~ file_name) # check if file already renamed in YYYYMMDD-hhss format 
      origin_file_name = $2
      #rename to origin
      new_file_name = File.join(output_path, origin_file_name+file_ext)
      f.puts "mv #{full_file_name} #{new_file_name}"
    else
      # for all others names rename to origin
      new_file_name = File.join(output_path, file_name+file_ext)
      f.puts "mv #{full_file_name} #{new_file_name}"
    end
  end #glob 
  f.puts
  f.puts "echo \"***GLOBAL PROCESSING***\""
  f.puts "echo \"***FILE RENAME***\""
  f.puts "exiftool -if '$FileName !~ m/^([0-9]{8}-[0-9]{4})/' '-FileName<${DateTimeOriginal}-#{foto_author_aka}_%f.%le' -d %Y%m%d-%H%M '#{output_path}' -P"
  f.puts "echo \"***Set FileModifyDate from EXIF DateTimeOriginal***\""
  f.puts "exiftool -if '$DateTimeOriginal ne $FileModifyDate' '-DateTimeOriginal>FileModifyDate' -d %Y:%m:%d:%H:%M:%S '#{output_path}'"
  f.puts "echo \"***Set EXIF Artist (photografer) tag***\""
  f.puts "exiftool '-Artist=#{foto_author}' '#{output_path}' -P -overwrite_original"
  f.puts "echo \"***Move to YEAR/MONTH folder***\""
  f.puts "exiftool '-Directory<DateTimeOriginal' -d #{output_path}/%Y/%m '#{output_path}'"
end
puts
puts "TOTAL files proceed: #{count}"

#making the script executable
File.chmod(0775, script_name)
