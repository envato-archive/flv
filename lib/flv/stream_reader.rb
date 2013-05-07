# coding: BINARY

require "stringio"

class FLV
  class StreamReader
    def initialize(io)
      @io = io
    end

    def self.for_string(str)
      new(StringIO.new(str))
    end

    def eof?
      @io.eof?
    end

    def seek(offset)
      @io.seek(offset, IO::SEEK_CUR)
    end

    def read_bytes(n)
      @io.read(n)
    end

    def read_byte
      @io.readbyte
    end

    def read_uint32_be
      read_bytes(4).unpack("L>").first
    end

    def read_uint24_be
      "\x00#{read_bytes(3)}".unpack("L>").first
    end

    def read_uint16_be
      read_bytes(2).unpack("S>").first
    end

    def read_sint16_be
      read_bytes(2).unpack("s>").first
    end

    def read_uint32_weird_endian
      lower = read_uint24_be
      higher = read_byte
      lower | (higher << 24)
    end

    def read_double_be
      read_bytes(8).unpack("G").first
    end
  end
end
