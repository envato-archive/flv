# coding: BINARY
require "flv/stream_reader"
require "flv/format_error"

class FLV
  class ScriptDataParser
    def initialize(str)
      @data_reader = StreamReader.for_string(str.dup.force_encoding("BINARY"))
    end

    def parse
      Hash[until_terminator(TERMINATOR).map {
        [expect_script_data_string, read_script_data_value]
      }]
    end

    def parse_single_value
      read_script_data_value
    end

  private
    def read_script_data_value
      case type = @data_reader.read_byte
      when  0 then read_script_data_number
      when  1 then read_script_data_boolean
      when  2 then read_script_data_string
      when  3 then read_script_data_object
      when  4 then read_script_data_movie_clip
      when  5 then read_script_data_null
      when  6 then read_script_data_undefined
      when  7 then read_script_data_reference
      when  8 then read_script_data_array
      when 10 then read_script_data_strict_array
      when 11 then read_script_data_date
      when 12 then read_script_data_long_string
      else
        raise FormatError, "unknown type #{type}"
      end
    end

    def read_script_data_number
      @data_reader.read_double_be
    end

    def read_script_data_string
      length = @data_reader.read_uint16_be
      @data_reader.read_bytes(length)
    end

    def read_script_data_boolean
      !@data_reader.read_byte.zero?
    end

    TERMINATOR = "\x00\x00\x09".force_encoding("BINARY").freeze

    def read_script_data_object
      Hash[until_terminator(TERMINATOR).map {
        [read_script_data_string, read_script_data_value]
      }]
    end

    def read_script_data_array
      # this value is ignored on purpose
      approx_array_length = @data_reader.read_uint32_be

      Hash[until_terminator(TERMINATOR).map {
        read_script_data_variable
      }]
    end

    def read_script_data_variable
      [read_script_data_string, read_script_data_value]
    end

    def read_script_data_strict_array
      count = @data_reader.read_uint32_be
      count.times.map { read_script_data_value }
    end

    def read_script_data_date
      time = @data_reader.read_double_be
      utc_offset_minutes = @data_reader.read_sint16_be
      Time.new(1970, 1, 1, 0, 0, 0, utc_offset_minutes * 60) + time
    rescue ArgumentError
      nil
    end

    def expect_script_data_string
      read_script_data_value.tap do |value|
        unless value.is_a?(String)
          raise FormatError, "expected string, have #{value.inspect}"
        end
      end
    end

    def until_terminator(term)
      return enum_for(:until_terminator, term) unless block_given?
      sz = term.bytesize
      loop do
        bytes = @data_reader.read_bytes(sz)
        return if bytes == term or bytes.nil?
        @data_reader.seek(-sz)
        yield
      end
    end
  end
end