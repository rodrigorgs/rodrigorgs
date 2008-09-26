#!/usr/bin/env jruby

CACHE_TO_S = lambda {|x| x.to_s}
CACHE_TO_I = lambda {|x| x.to_i}
CACHE_TO_F = lambda {|x| x.to_f}
CACHE_INSPECT = lambda {|x| x.inspect}
CACHE_EVAL = lambda {|x| eval(x)}
CACHE_IDENTITY = lambda {|x| x}

# TODO: sometimes the client function needs to write to/read from file itself. Think about a variation where to_string/to_value is, in fact, a call to a block that writes/reads the file.
def cache(function, dir, filename, to_string, to_value)
	path = "#{dir}/#{filename}"
	if File.exists? path
		#puts "Getting value from cache"
		return to_value.call IO.read(path)
	else
		#puts "Computing value"
		ret = function.call
		File.open(path, 'w') { |f| f.write to_string.call(ret) }
		return ret
	end
end

# # Sample Code
# puts cache(lambda { puts 'Caching'; 2 }, '.', 'dois', CACHE_TO_S, CACHE_TO_I)
