require "./object"

class IO
    def read_sexp : Scheme::SchemeObject
      return Scheme::Eof.the if !(drain_ws)
      case cpeek
      when nil then Scheme::Eof.the
      when '('  then sexp_read_cons
      #when "\"" then sexp_read_string
      when '#' then sexp_read_hash
      else
        tok = sexp_read_tok
        case tok
        when /^[+-]?\d+$/      then tok.to_i.to_scheme
        when /^[+-]?\d+\.\d+$/ then tok.to_f.to_scheme
        else Scheme::Symbol.intern(tok)
        end
      end
    end

    @ungot : Char? = nil

    def ungetc(ch)
      @ungot = ch
    end

    def getc
      if @ungot.nil?
        r = read_byte
        if r.nil?
          nil
        else
          r.unsafe_chr
        end
      else
        ch = @ungot
        @ungot = nil
        ch
      end
    end

    def each_char_u
      loop do
        ch = getc
        if ch.nil?
          break
        else
          yield ch
        end
      end
    end

    private def cpeek : Char?
      ch = getc
      if ch
        ungetc(ch)
        ch
      end
    end

    private def drain_ws
      each_char_u do |ch|
        if /^\S/ === ch.to_s
          ungetc(ch)
          return ch
        end
      end
      nil
    end

    private def assert_next_char (ch)
      rch = getc
      raise "expected #{ch.inspect} got #{rch.inspect}" if rch != ch
    end

    private def sexp_read_cdr_cons
      drain_ws
      case cpeek
      when ')'
        getc
        nil.to_scheme
      when '.'
        getc
        val = read_sexp
        drain_ws
        assert_next_char ')'
        val
      else
        Scheme::Cons.new(read_sexp, sexp_read_cdr_cons)
      end
    end

    private def sexp_read_cons
      assert_next_char '('
      sexp_read_cdr_cons
    end

    private def sexp_read_tok
      str = ""
      each_char_u do |ch|
        case ch.to_s
        when /^[\(\)\s]$/
          ungetc(ch)
          break
        else
          str += ch
        end
      end
      str
    end

   # private def sexp_read_string
   #   str = getc
   #   each_char_u do |ch|
   #     str << ch;
   #     case ch
   #     when '\\'
   #       str << getc
   #     when '"'
   #       break
   #     end
   #   end
   #   str.undump
   # end

    private def sexp_read_hash
      assert_next_char '#'
      tok = sexp_read_tok
      case tok
      when "t"
        true.to_scheme
      when "f"
        false.to_scheme
      else
        raise "unrecognised hash sequence"
      end
    end
end
