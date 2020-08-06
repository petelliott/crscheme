require "./object"

module Scheme
  abstract class Builtin < SchemeObject
    @@name : ::String = ""
    def to_s
      "#<builtin #{@@name}>"
    end

    @@builtins = Hash(Symbol,Builtin).new

    def self.builtins
      @@builtins
    end

    def self.add_builtin(sym, b)
      @@builtins[sym] = b
    end
  end

  macro builtin(name, cname, fn)
    class Builtin{{cname.id}} < Builtin
      @@name = {{name}}
      {{fn}}
    end
    Builtin.add_builtin(Symbol.intern({{name}}), Builtin{{cname.id}}.new)
  end

  builtin "car", Car, def call(args)
    arg = args[0]
    if arg.is_a? Cons
      arg.car
    else
      raise "expected Cons got #{typeof(arg)}"
    end
  end

  builtin "cdr", Cdr, def call(args)
    arg = args[0]
    if arg.is_a? Cons
      arg.cdr
    else
      raise "expected Cons got #{typeof(arg)}"
    end
  end

  builtin "cons", Cons, def call(args)
      Cons.new(args[0], args[1])
  end

  builtin "+", Plus, def call(args)
    a = 0.to_scheme
    args.each do |arg|
      a += arg
    end
    a
  end

  builtin "-", Minus, def call(args)
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

  builtin "write", Write, def call(args)
    print args[0].to_s
    Undefined.the
  end

  builtin "display", Display, def call(args)
    if (s = args[0]).is_a? String
      print s.to_crystal
    else
      print s.to_s
    end
    Undefined.the
  end

  builtin "newline", Newline, def call(args)
    puts ""
    Undefined.the
  end

  builtin "vector", Vector, def call(args)
    args.to_scheme
  end

  builtin "list", List, def call(args)
    args.to_scheme.to_list
  end

  builtin "list->vector", ListToVector, def call(args)
    obj = args[0]
    # blame crystal
    if obj.is_a? Cons
      obj.to_a.to_scheme
    elsif obj.is_a? Nil
      obj.to_a.to_scheme
    else
      raise "#{obj.to_s} is not a list"
    end
  end

  builtin "vector->list", VectorToList, def call(args)
    obj = args[0]
    if obj.is_a? Vector
      obj.to_list
    else
      raise "#{obj.to_s} is not a vector"
    end
  end
end
