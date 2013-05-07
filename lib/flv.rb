require "flv/version"
require "flv/stream_reader"
require "flv/format_error"
require "flv/tag"

class FLV
  def self.read(path)
    new(File.open(path, "rb"))
  end

  AUDIO_FLAG = 0x04
  VIDEO_FLAG = 0x01

  attr_reader :flags

  def initialize(io)
    @io = io
    @reader = StreamReader.new(io)
    read_header
    read_useless_footer
  end

  def audio?
    (flags & AUDIO_FLAG).nonzero?
  end

  def video?
    (flags & VIDEO_FLAG).nonzero?
  end

  def tags
    @tags ||= each_tag.to_a
  end

  def each_tag
    return enum_for(:each_tag) unless block_given?

    until @io.eof?
      yield Tag.read(@io)
    end
  end

private
  def read_header
    raise FormatError, "bad header" unless @reader.read_bytes(3) == "FLV"
    raise FormatError, "bad version" unless @reader.read_byte == 1
    @flags = @reader.read_byte
    raise FormatError, "bad header size" unless @reader.read_uint32_be == 9
  end

  def read_useless_footer
    raise FormatError, "expected useless footer to be zero" unless @reader.read_uint32_be == 0
  end
end
