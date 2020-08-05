require "./object"
require "./read"
require "./interpreter"
require "option_parser"

Interp = Scheme::State.new

def spawn_repl
  loop do
    print "> "
    begin
      result = Interp.eval(STDIN.read_sexp)
    rescue ex
      STDERR.puts ex.message
      next
    end

    case result
    when Scheme::Eof.the
      break
    when Scheme::Undefined.the
    else
      puts result.to_s
    end
  end

  puts ""
end

def load_file(io)
  loop do
    input = io.read_sexp
    break if input == Scheme::Eof.the
    Interp.eval(input)
  end
end

script = false

OptionParser.parse do |parser|
  parser.on("-s", "--script", "don't launch repl") do
    script = true
  end
end

ARGV.each do | filename |
  File.open(filename) do |file|
    load_file(file)
  end
end

if !script
  spawn_repl
end
