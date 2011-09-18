#!/usr/bin/env ruby -w
require "rubygems"
require "yaml"
require "mini_exiftool"

def find_first_yaml_file(dir_to_process)
  Dir.chdir(dir_to_process)
  yaml_file = nil
  Dir.glob("*.yaml") do |file|
    yaml_file = file
    break
  end  
  return yaml_file  
end

def read_input_params
    # read input args
    dir_to_process = ARGV[0]||Dir.pwd
    if not File.exist?(dir_to_process)
      puts "#{dir_to_process} does not exist"
      exit
    end
    if not File.directory?(dir_to_process)
      puts "#{dir_to_process} is not a Directory"
      exit
    end

    yaml_name = ARGV[1]||find_first_yaml_file(dir_to_process)
    # read script_options
    if File.file?(yaml_name)
      begin
        options = YAML.load_file(yaml_name)
      rescue ArgumentError => e
        puts "Could not parse YAML #{yaml_name}: #{e.message}"
        exit
      end
    else
      puts "File #{yaml_name} does not exist ..."
      exit
    end
    return [dir_to_process, options]
end

# Foto object
class FotoObject

  # Class attributes and methods
  @@collection = []

  def self.collection
    @@collection
  end
  
  def self.scan dir_to_process=Dir.pwd, ext_to_process=["jpg"]
    @@collection.clear
    Dir.chdir(dir_to_process)
    fmask = "**/*.{#{ext_to_process * ","}}"
    puts
    puts "Scanning #{ext_to_process} files"
    puts "DIR: #{dir_to_process}, MASK: #{fmask}"
    
    Dir.glob(fmask) do |file|
      print "*"
      self.new(file)
    end #glob
    puts 
    puts "TOTAL files scanned: #{self.collection.count}"    
  end
  
  # Instance attributes and methods
  attr_reader :filename_original
  attr_accessor :name, :extention, :directory, :errors
  
  def initialize filename=nil
    @extention = File.extname filename
    @name = File.basename filename, extention
    @directory = File.expand_path(File.dirname(filename))
    @filename_original = File.realpath filename
    @@collection << self
  end
end

# MAIN PART
# initializing
dir_to_process, options = read_input_params

video_ext = options[:input_parameter][:video_ext]||["mov"]
fmask_video = video_ext.collect {|x| File.join("**", "*."+x)}
audio_ext = options[:input_parameter][:audio_ext]||["wav"]
fmask_audio = audio_ext.collect {|x| File.join("**", "*."+x)}

foto_author_aka = options[:output_parameter][:foto_author_aka]||"ANB"
foto_author = options[:output_parameter][:foto_author]||"Andrey Bizyaev, aka ANB (c)"

output_path = options[:input_parameter][:output_path]||"." 
Dir.mkdir(output_path) unless File.exists?(output_path)

FotoObject.scan(dir_to_process, options[:input_parameter][:foto_ext])
p FotoObject.collection

=begin
begin 
  photo = MiniExiftool.new full_file_name, :convert_encoding => true
rescue MiniExiftool::Error => e
  $stderr.puts e.message
  exit -1
end
puts photo.FileName
puts "DTO: #{photo.DateTimeOriginal.strftime('%Y-%m-%d %H:%M')}"

puts photo.DateTimeOriginal
puts photo.FileModifyDate
if photo.DateTimeOriginal
  if photo.DateTimeOriginal != photo.FileModifyDate
     puts "!!!"
  end
else
  #photo.DateTimeOriginal = photo.FileModifyDate
  #photo.save
  puts "!! !!"     
end
# Print the metadata
#photo.tags.sort.each do |tag|
#  puts tag.ljust(28) + photo[tag].to_s
#end
#p photo.tags

  #change flags
#    f.puts "chflags nouchg #{full_file_name}"
#    f.puts "chmod go=u-w #{full_file_name}" 
  
  if (/^(\d{8}-\d{4}-\w{3}_)(.*)/ =~ file_name) #check if file already renamed to YYYYMMDD-hhss-AUT format
    origin_file_name = $2
    #move - do not change name origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"   
    #puts new_file_name
  
  elsif (/^(\d{8}-\d{4}_)(.*)/ =~ file_name) # check if file already renamed in YYYYMMDD-hhss format 
    origin_file_name = $2
    #rename to origin
    new_file_name = File.join(output_path, origin_file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  else
    # for all others names rename to origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  end
=end

puts
puts "Running on AUDIO"
puts "DIR: #{dir_to_process} MASK: #{fmask_audio.inspect}"
count_audio = 0
Dir.glob(fmask_audio) do |file|
  print "*"
  count_audio += 1
#    f.puts "echo \"*** #{count} **\""
  full_file_name = File.realpath(file)
  file_ext = File.extname(file)
  file_name = File.basename(file, file_ext)
puts full_file_name 
  #change flags
#    f.puts "chflags nouchg #{full_file_name}"
#    f.puts "chmod go=u-w #{full_file_name}" 
  
  if (/^(\d{8}-\d{4}-\w{3}_)(.*)/ =~ file_name) #check if file already renamed to YYYYMMDD-hhss-AUT format
    origin_file_name = $2
    #move - do not change name origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"   
    #puts new_file_name
  
  elsif (/^(\d{8}-\d{4}_)(.*)/ =~ file_name) # check if file already renamed in YYYYMMDD-hhss format 
    origin_file_name = $2
    #rename to origin
    new_file_name = File.join(output_path, origin_file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  else
    # for all others names rename to origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  end
end #glob 
puts "TOTAL files proceed: #{count_audio}"


puts
puts "Running on VIDEO"
puts "DIR: #{dir_to_process} MASK: #{fmask_video.inspect}"
count_video = 0
Dir.glob(fmask_video) do |file|
  print "*"
  count_video += 1
#    f.puts "echo \"*** #{count} **\""
  full_file_name = File.realpath(file)
  file_ext = File.extname(file)
  file_name = File.basename(file, file_ext)
puts full_file_name 
  #change flags
#    f.puts "chflags nouchg #{full_file_name}"
#    f.puts "chmod go=u-w #{full_file_name}" 
  
  if (/^(\d{8}-\d{4}-\w{3}_)(.*)/ =~ file_name) #check if file already renamed to YYYYMMDD-hhss-AUT format
    origin_file_name = $2
    #move - do not change name origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"   
    #puts new_file_name
  
  elsif (/^(\d{8}-\d{4}_)(.*)/ =~ file_name) # check if file already renamed in YYYYMMDD-hhss format 
    origin_file_name = $2
    #rename to origin
    new_file_name = File.join(output_path, origin_file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  else
    # for all others names rename to origin
    new_file_name = File.join(output_path, file_name+file_ext)
#      f.puts "mv #{full_file_name} #{new_file_name}"
    #puts new_file_name
  end
end #glob
puts "TOTAL files proceed: #{count_video}"

#making the script executable
#File.chmod(0775, script_name)

# http://miniexiftool.rubyforge.org/
# gem install mini_exiftool