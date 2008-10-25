#!/usr/bin/env jruby

CACHE_TO_S = lambda {|x| x.to_s}
CACHE_TO_I = lambda {|x| x.to_i}
CACHE_TO_F = lambda {|x| x.to_f}
CACHE_INSPECT = lambda {|x| x.inspect}
CACHE_EVAL = lambda {|x| eval(x)}
CACHE_IDENTITY = lambda {|x| x}

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

def cache2(read, write, &block)
	begin	
		return read.call
	rescue
		ret = block.call
		write.call ret
		return ret
	end
end

# TODO: preciso de algo diferente. Talvez o fluxo de controle deva ser
# controlado pelas funcoes de caching. Imagine que preciso fazer caching
# de 900 valores. Se gravo cada valor separadamente, a leitura sera
# ineficiente. No entanto, se considero os 900 valores em apenas uma
# transacao, entao preciso esperar a computacao completar para ter fazer
# o caching dos 900 valores (alem disso, nao posso paralelizar a computacao).
# Entao preciso de suporte a caching parcial, e isso so pode ser feito se
# o fluxo de controle for controlado pelas funcoes de caching, pois apenas
# elas podem julgar se o caching esta completo ou eh apenas parcial.
# (cache miss)
