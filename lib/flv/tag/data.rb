require "flv/tag"
require "flv/stream_reader"
require "flv/format_error"
require "flv/script_data_parser"

class FLV
  class Tag
    class Data < Tag
      attr_reader :data

      def decode_raw_data
        @data = ScriptDataParser.new(raw_data).parse
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
    end
  end
end
