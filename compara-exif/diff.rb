require 'denise'
require 'rodrigo'

denise = y
rodrigo = x

repetidos = []
denise.each_pair do |info, path|
  if rodrigo.keys.include? info
    repetidos << path
    #p path
  else
    p path
  end
end

f = File.open('diferenca', 'w')
f.puts repetidos.inspect

