require "./object.cr"
require "./builtin.cr"

module Scheme

  class State
    def initialize(@parent : State? = nil)
      @scope = Hash(Symbol, SchemeObject).new

      #insert builtins at highest level
      if @parent.nil?
        Builtin.builtins.each do |k, v|
          if (sk = k.to_scheme).is_a? Symbol
            @scope[sk] = v
          end
        end
      end
    end

    def []?(idx)
      val = @scope[idx]?
      if val
        val
      elsif (parent = @parent).nil?
        nil
      else
        parent[idx]?
      end
    end

    def [](idx)
      val = self[idx]?
      if val
        val
      else
        raise "unbound variable #{idx}"
      end
    end

    def []=(idx, val)
      @scope[idx] = val
    end

    def set!(idx, val)
      if @scope[idx]?
        @scope[idx] = val
      elsif (parent = @parent).nil?
        raise "attempt to set unbound variable #{idx.to_s}"
      else
        parent.set!(idx, val)
      end
    end

    def eval_call(fn, args)
      fn.call(
        args.map do |obj|
          eval(obj).as SchemeObject
        end)
    end

    def eval(obj) : SchemeObject
      case obj
      when Symbol
        self[obj]
      when Cons
        rest = if (cdr = obj.cdr).is_a? Cons
                 cdr.to_a
               else
                 [] of SchemeObject
               end

        case obj.car
        when Symbol.intern "define"
          eval_define rest
        when Symbol.intern "set!"
          eval_set! rest
        when Symbol.intern "if"
          eval_if rest
        when Symbol.intern "quote"
          eval_quote rest
        else
          eval_call(eval(obj.car), rest)
        end
      else
        obj
      end
    end

    def eval_if(args)
      if eval(args[0]) != Boolean.false
        eval(args[1])
      else
        eval(args[2])
      end
    end

    def eval_quote(args)
      args[0]
    end

    def eval_define(args)
      if (ll = args[0]).is_a? Cons
        raise "lambda-defines are unimplemented"
      elsif (name = args[0]).is_a? Symbol
        self[name] = eval(args[1])
      else
        raise "invalid argument to define"
      end
      Undefined.the
    end

    def eval_set!(args)
      if (name = args[0]).is_a? Symbol
        set!(name, eval(args[1]))
      else
        raise "invalid argument to set!"
      end
      Undefined.the
    end
  end
end
