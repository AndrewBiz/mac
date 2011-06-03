#!/usr/bin/env ruby -w
require "yaml"

a = {:par1 => 'val1', :par2 => 'val2', :par3 => 'val3'}
puts a.to_yaml
ccc = {:par1 => 'val1', :par2 => 'val2', :par3 => 'val3'}
puts ccc.to_yaml

b = {:chapter1 => {:ppp1 => 'val1', :par2 => 'val2', :par3 => 'val3'}, :chapter2 => {:ptp => 'val1', :par2 => 'val2', :par3 => 'val3'}}
puts b.to_yaml
puts b[:chapter2].to_hash

begin
  fff = YAML.load_file('test.yaml')
rescue ArgumentError => e
  puts "Could not parse YAML: #{e.message}"
end
option_name = fff[:option_name]
option_value = fff[:option_value]
puts option_value[:album]
