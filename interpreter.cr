require "./object.cr"
require "./builtin.cr"

module Scheme

  class Closure < SchemeObject
    def initialize(@lambdalist : List, @body : Array(SchemeObject),
                   @state : State, @name : ::String? = nil)
    end

    def to_s
      if (name = @name).nil?
        "#<closure>"
      else
        "#<closure #{name}>"
      end
    end

    def call(args)
      newstate = @state.nest

      if (ll = @lambdalist).is_a? Cons
        ll.zip(args).each do |name, val|
          if name.is_a? Symbol
            newstate[name] = val
          end
        end
      elsif ll.is_a? Nil
      else
        raise "non-list lambda-list"
      end

      ret = Undefined.the
      @body.each do |expr|
        ret = newstate.eval(expr)
      end
      ret
    end
  end

  class State
    def initialize(@parent : State? = nil)
      @scope = Hash(Symbol, SchemeObject).new

      #insert builtins at highest level
      if @parent.nil?
        Builtin.builtins.each do |k, v|
          @scope[k] = v
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
        raise "unbound variable #{idx.to_s}"
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

    def nest
      self.class.new(self)
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
        when Symbol.intern "lambda"
          eval_lambda rest
        when Symbol.intern "and"
          eval_and rest
        when Symbol.intern "or"
          eval_or rest
        when Symbol.intern "begin"
          eval_begin rest
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
        if (name = ll.car).is_a? Symbol
          self[name] = Closure.new(ll.cdr, args[1..], self, name.to_s)
        else
          raise "invalid argument to define"
        end
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

    def eval_lambda(args)
      if (ll = args[0]).is_a? List
        Closure.new(ll, args[1..], self)
      else
        raise "non-list lambda-list"
      end
    end

    def eval_and(args)
      result = true.to_scheme
      args.each do |arg|
        result = eval(arg)
        if result == false.to_scheme
          break
        end
      end
      result
    end

    def eval_or(args)
      result = false.to_scheme
      args.each do |arg|
        result = eval(arg)
        if result != false.to_scheme
          break
        end
      end
      result
    end

    def eval_begin(args)
      result = Undefined.the
      args.each do |arg|
        result = eval(arg)
      end
      result
    end
  end
end
