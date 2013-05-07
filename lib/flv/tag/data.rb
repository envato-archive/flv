require "flv/tag"
require "flv/stream_reader"
require "flv/format_error"

class FLV
  class Tag
    class Data < Tag
      attr_reader :data

      def decode_raw_data
        @data_reader = StreamReader.for_string(raw_data.dup.force_encoding("BINARY"))
        @data = read_script_data_objects
      end

      def inspect
        "#<#{self.class} #{data.inspect}>"
      end

      def duration
        meta_data["duration"]
      end

      def width
        meta_data["width"]
      end

      def height
        meta_data["height"]
      end

      def video_data_rate
        meta_data["videodatarate"]
      end

      def frame_rate
        meta_data["framerate"]
      end

      def video_codec_id
        meta_data["videocodecid"]
      end

      def audio_data_rate
        meta_data["audiodatarate"]
      end

      def audio_delay
        meta_data["audiodelay"]
      end

      def audio_codec_id
        meta_data["audiocodecid"]
      end

      def seek_to_end?
        !!meta_data["canSeekToEnd"].nonzero?
      end

    private
      def meta_data
        data["onMetaData"]
      end

      def read_script_data_value
        case type = @data_reader.read_byte
        when  0 then read_script_data_number
        when  1 then read_script_data_boolean
        when  2 then read_script_data_string
        when  3 then read_script_data_objects
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
        # 'G' means double precision big endian floating point number
        @data_reader.read_bytes(8).unpack("G").first
      end

      def read_script_data_string
        length = @data_reader.read_uint16_be
        @data_reader.read_bytes(length)
      end

      def read_script_data_boolean
        @data_reader.read_byte.nonzero?
      end

      TERMINATOR = "\x00\x00\x09".force_encoding("BINARY").freeze

      def read_script_data_objects
        Hash[until_terminator(TERMINATOR).map {
          [expect_script_data_string, read_script_data_value]
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

      def expect_script_data_string
        read_script_data_value.tap do |value|
          raise FormatError, "expected string, have #{value.inspect}" unless value.is_a?(String)
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
end
