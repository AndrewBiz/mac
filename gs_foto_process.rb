#!/usr/bin/env ruby -w
require "yaml"
=begin
class Dir
  def self.foreach_recursive(dir_to_process, fmask, &block)
    Dir.foreach(dir_to_process) do |item|
      if File.directory?(item)
        if (item!=".") and (item!="..")
          foreach_recursive(item, fmask, &block)
        end
      else #item=file
        matched = false
        fmask.collect{|x| matched = File.fnmatch(x, item)||matched}
        yield File.expand_path(dir_to_process), item if matched 
      end
    end
  end
end
=end

# read input args
yaml_name = ARGV[0]||"foto_process_options.yaml"
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
if not File.exists?(output_path)
  Dir.mkdir(output_path)
end

puts "DIR: #{dir_to_process} MASK: #{fmask.inspect}, script: #{script_name}"
# gen script
count = 0
File.open(script_name, "w+") do |f|
  f.puts "#!/bin/bash"
#  Dir.foreach_recursive(dir_to_process, fmask) do |dir, file|
  Dir.glob(fmask) do |file|
    print "*"
    count += 1
    f.puts "#*** #{count}"
#    full_file_name = File.join(dir, file)
    full_file_name = File.realpath(file)
    # get the actual extention
    file_ext = File.extname(file)
    #if (/\.(.*)$/ =~ file) then file_ext = $1 end
    # get the actual name w/o extention
    file_name = File.basename(file, file_ext)
    #change flags
    f.puts "chflags nouchg #{full_file_name}"
    f.puts "chmod go=u-w #{full_file_name}" 
    
    if (/^(\d{8}-\d{4}-\w{3}_)(.*)/ =~ file_name) #check if file already renamed to YYYYMMDD-hhss-AUT format
      origin_file_name = $2
      #move - do not origin
      new_file_name = File.join(output_path, file_name+file_ext)
      f.puts "mv #{full_file_name} #{new_file_name}"   
      #puts new_file_name
    
    elsif (/^(\d{8}-\d{4}_)(.*)/ =~ file_name) # check if file already renamed in YYYYMMDD-hhss format 
      origin_file_name = $2
      #rename to origin
      new_file_name = File.join(output_path, origin_file_name+file_ext)
      f.puts "mv #{full_file_name} #{new_file_name}"
      #puts new_file_name
    else
      # for all others names rename to origin
      new_file_name = File.join(output_path, file_name+file_ext)
      f.puts "mv #{full_file_name} #{new_file_name}"
      #puts new_file_name
    end
  end #glob 
  f.puts "#***GLOBAL PROCESSING***"
  f.puts "#***FILE RENAME***"
  f.puts "exiftool -if '$FileName !~ m/^([0-9]{8}-[0-9]{4})/' '-FileName<${DateTimeOriginal}-#{foto_author_aka}_%f.%le' -d %Y%m%d-%H%M '#{output_path}' -P"
  f.puts "#***Set FileModifyDate from EXIF DateTimeOriginal***"
  f.puts "exiftool -if '$DateTimeOriginal ne $FileModifyDate' '-DateTimeOriginal>FileModifyDate' -d %Y:%m:%d:%H:%M:%S '#{output_path}'"
  f.puts "#***Set EXIF Artist (photografer) tag***"
  f.puts "exiftool '-Artist=#{foto_author}' '#{output_path}' -P -overwrite_original"
  f.puts "#***Move to YEAR/MONTH folder***"
  f.puts "exiftool '-Directory<DateTimeOriginal' -d #{output_path}/%Y/%m '#{output_path}'"
  #exiftool -FileName -DateTimeOriginal -FilePermissions -d %Y%m%d-%H%M PATH -f
end
puts
puts "TOTAL files proceed: #{count}"

#making the script executable
File.chmod(0775, script_name)

# http://miniexiftool.rubyforge.org/
# gem install mini_exiftool