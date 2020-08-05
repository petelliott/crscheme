require "./object"

module Scheme
  abstract class Builtin < SchemeObject
    @@name : String = ""
    def to_s
      "#<builtin #{@@name}>"
    end

    @@builtins = {car: BuiltinCar.new, cdr: BuiltinCdr.new,
                  cons: BuiltinCons.new, "+": BuiltinPlus.new,
                  "-": BuiltinMinus.new}

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

  class BuiltinPlus < Builtin
    @@name = "+"

    def call(args)
      a = 0.to_scheme
      args.each do |arg|
        a += arg
      end
      a
    end
  end

  class BuiltinMinus < Builtin
    @@name = "-"

    def call(args)
      if args.size == 0
        raise "wrong number of arguments to -"
      elsif args.size == 1
        -args[0]
      else
        a = args[0]
        args[1..].each do |arg|
          a -= arg
        end
        a
      end
    end
  end
end
