require '../cache'

puts cache(lambda { puts 'Primeira vez'; 2 }, '.', 'dois', lambda {|x| x.to_s}, lambda {|x| x.to_i})
