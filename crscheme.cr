require "./object"
require "./read"


loop do
  print "> "
  input = STDIN.read_sexp
  case input
  when Scheme::Eof.the
    break
  when Scheme::Undefined.the
  else
    puts input.to_s
  end
end

puts ""
