require "flv/stream_reader"
require "flv/format_error"
require "flv/tag/data"
require "flv/tag/audio"
require "flv/tag/video"

class FLV
  class Tag
    METADATA_TYPE = 0x12
    AUDIO_TYPE    = 0x08
    VIDEO_TYPE    = 0x09

    attr_reader :length, :timestamp, :raw_data, :footer

    def self.read(io)
      case io.readbyte
      when METADATA_TYPE  then Data.new(io)
      when AUDIO_TYPE     then Audio.new(io)
      when VIDEO_TYPE     then Video.new(io)
      end
    end

    def initialize(io)
      @reader = StreamReader.new(io)
      read
    end

    def inspect
      "#<#{self.class}>"
    end

  private
    def decode_raw_data
      # implemented in subclasses
    end

    def read
      read_header
      read_raw_data
      read_footer
      decode_raw_data
    end

    def read_header
      @length     = @reader.read_uint24_be
      @timestamp  = @reader.read_uint32_weird_endian
      raise FormatError, "bad stream id" unless @reader.read_uint24_be == 0
    end

    def read_raw_data
      @raw_data = @reader.read_bytes(length)
    end

    def read_footer
      @footer = @reader.read_uint32_be
    end
  end
end
