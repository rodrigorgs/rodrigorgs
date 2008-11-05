#!/usr/bin/env ruby

def double(array)
  array.map { |x| 2 * x }
end

def sum(array, number)
  i = number.to_i
  array.map { |x| x + i }
end

def output(array)
  p array
end

def ssrun(string)
  output = nil
  string.split('|').each do |cmd|
    tokens = cmd.split
    func = tokens[0]
    args = tokens[1..-1]

    args = [output] + args unless output.nil?
    #puts "#{func} #{args.inspect[1..-2]}"
    if args.empty?
      output = Kernel.send(func)
    else
      output = Kernel.send(func, *args)
    end
    #puts "==> #{output.inspect}"
  end
end


def ssrun_help
  puts <<EOT 
Usage: #{$0} "command_1 | command_2 | ... | command_n"

where command is function_name param_1 param_2 ... param_n

This script will run each function with the given parameters (interpreted as
strings) plus the output of the previous command.

Example:
  #{$0} "eval [1,2,3] | double | sum 1 | p"

This will produce the following sequence of calls

eval "[1,2,3]"       # returns [1, 2, 3]
double [1, 2, 3]     # returns [2, 4, 6]
sum [2, 4, 6], "1"   # returns [3, 5, 7]
p [3, 5, 7]          # returns nil and outputs "[3, 5, 7]"

EOT
  exit 1
end

if __FILE__ == $0
  dirname = File.dirname(__FILE__)
  Dir.glob("#{dirname}/**/*.rb").each { |filename| require filename }

  ssrun_help if ARGV.empty?
  ssrun ARGV.join(' ')
end
