require "./object"
require "./read"

loop do
  print "> "
  puts STDIN.read_sexp.to_s
end
