
module Scheme
  abstract class SchemeObject
    def to_s
      "#<object:#{object_id}>"
    end

    def call(args)
      raise "object #{self} is not callable."
    end

    def +(other)
      raise "object #{self} cannot be added"
    end

    def -
      raise "object #{self} cannot be negated"
    end

    def -(other)
      raise "object #{self} cannot be subtracted"
    end
  end

  abstract class SchemeNumber < SchemeObject
    def +(other)
      if other.is_a? SchemeNumber
        (to_crystal + other.to_crystal).to_scheme
      else
        raise "object #{other} cannot be added"
      end
    end

    def -
        (- (to_crystal)).to_scheme
    end

    def -(other)
      if other.is_a? SchemeNumber
        (to_crystal - other.to_crystal).to_scheme
      else
        raise "object #{other} cannot be subtracted"
      end
    end
  end

  class Fixnum < SchemeNumber
    def initialize(@value : Int64)
    end

    def to_s
      "#{@value}"
    end

    def to_crystal
      @value
    end
  end

  class Flonum < SchemeNumber
    def initialize(@value : Float64)
    end

    def to_s
      "#{@value}"
    end

    def to_crystal
      @value
    end
  end


  class Symbol < SchemeObject
    @@intern_tab = Hash(String, Symbol).new

    private def initialize(@value : String)
    end

    def self.intern(str)
      if @@intern_tab[str]?.nil?
        @@intern_tab[str] = new(str)
      end
      @@intern_tab[str]
    end

    def to_s
      @value
    end
  end

  class Boolean < SchemeObject
    private def initialize(@value : Bool)
    end

    @@true = new true
    @@false = new false

    def self.true
      @@true
    end

    def self.false
      @@false
    end

    def self.intern(value : Bool)
      if value
        self.true
      else
        self.false
      end
    end

    def to_crystal
      @value
    end

    def to_s
      if @value
        "#t"
      else
        "#f"
      end
    end
  end

  class Cons < SchemeObject
    include Enumerable(SchemeObject)
    getter car
    getter cdr

    def initialize(@car : SchemeObject, @cdr : SchemeObject)
    end

    def to_s
      "(#{inner_to_s})"
    end

    protected def inner_to_s
      if @cdr.is_a? Scheme::Nil
        @car.to_s
      elsif (cdr = @cdr).is_a? Cons
        "#{@car.to_s} #{cdr.inner_to_s}"
      else
        "#{@car.to_s} . #{@cdr.to_s}"
      end
    end

    def each
      cur = self
      while cur.is_a? Cons
        yield cur.car
        cur = cur.cdr
      end
    end
  end

  abstract class SingletonSchemeObject < SchemeObject
    @@classname : String = "object"
    def to_s
      "#<#{@@classname.downcase}>"
    end
  end

  class Nil < SingletonSchemeObject
    @@classname = "nil"
    @@instance = Nil.new
    include Enumerable(SchemeObject)

    def self.the
      @@instance
    end

    def to_crystal
      nil
    end

    def to_s
      "()"
    end

    def each(&block : SchemeObject -> _)
    end
  end

  alias List = Nil | Cons

  class Eof < SingletonSchemeObject
    @@classname = "EOF"
    @@instance = Eof.new

    def self.the
      @@instance
    end
  end

  class Undefined < SingletonSchemeObject
    @@classname = "undefined"
    @@instance = Undefined.new

    def self.the
      @@instance
    end
  end

end

struct Int
  def to_scheme
    Scheme::Fixnum.new(self.to_i64)
  end
end

struct Float
  def to_scheme
    Scheme::Flonum.new(self.to_f64)
  end
end

struct Symbol
  def to_scheme
    Scheme::Symbol.intern(to_s)
  end
end

struct Bool
  def to_scheme
    Scheme::Boolean.intern(self)
  end
end

struct Nil
  def to_scheme
    Scheme::Nil.the
  end
end
