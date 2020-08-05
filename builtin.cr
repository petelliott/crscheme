require "./object"

module Scheme
  abstract class Builtin < SchemeObject
    @@name : String = ""
    def to_s
      "#<builtin #{@@name}>"
    end

    @@builtins = {car: BuiltinCar.new, cdr: BuiltinCdr.new,
                  cons: BuiltinCons.new}

    def self.builtins
      @@builtins
    end
  end

  class BuiltinCar < Builtin
    @@name = "car"
    def call(args)
      arg = args[0]
      if arg.is_a? Cons
        arg.car
      else
        raise "expected Cons got #{typeof(arg)}"
      end
    end
  end

  class BuiltinCdr < Builtin
    @@name = "cdr"
    def call(args)
      arg = args[0]
      if arg.is_a? Cons
        arg.cdr
      else
        raise "expected Cons got #{typeof(arg)}"
      end
    end
  end

  class BuiltinCons < Builtin
    @@name = "cons"
    def call(args)
      Cons.new(args[0], args[1])
    end
  end
end
