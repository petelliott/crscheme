require "./object"
require "./read"
require "./interpreter"

interp = Scheme::State.new

loop do
  print "> "
  result = interp.eval(STDIN.read_sexp)
  case result
  when Scheme::Eof.the
    break
  when Scheme::Undefined.the
  else
    puts result.to_s
  end
end

puts ""
