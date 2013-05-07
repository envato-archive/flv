# coding: BINARY

require "flv/stream_reader"
require "stringio"

describe FLV::StreamReader do
  let(:string) { "\xde\xad\xbe\xef\x00\xfa\xca\xde" }
  let(:io) { StringIO.new(string) }
  subject { FLV::StreamReader.new(io) }

  describe "#eof?" do
    let(:val) { mock }

    it "should delegate to the io" do
      io.should_receive(:eof?).and_return(val)
      subject.eof?.should == val
    end
  end

  describe "#read_bytes" do
    it "reads the specified number of bytes" do
      subject.read_bytes(8).should == string
    end

    it "saves its spot in the stream" do
      subject.read_bytes(4).should == "\xde\xad\xbe\xef"
      subject.read_bytes(4).should == "\x00\xfa\xca\xde"
    end
  end

  describe "#read_byte" do
    it "returns fixnums" do
      subject.read_byte.should == 0xde
      subject.read_byte.should == 0xad
    end
  end

  describe "#read_uint32_be" do
    it "reads big endian unsigned 32 bit integers" do
      subject.read_uint32_be.should == 0xdeadbeef
      subject.read_uint32_be.should == 0x00facade
    end
  end

  describe "#read_uint24_be" do
    it "reads big endian unsigned 24 bit integers" do
      subject.read_uint24_be.should == 0xdeadbe
      subject.read_uint24_be.should == 0xef00fa
    end
  end

  describe "#read_uint16_be" do
    it "reads big endian unsigned 16 bit integers" do
      subject.read_uint16_be.should == 0xdead
      subject.read_uint16_be.should == 0xbeef
    end
  end

  describe "#read_uint32_weird_endian" do
    it "reads FLV's super weird mixed endian properly" do
      subject.read_uint32_weird_endian.should == 0xefdeadbe
      subject.read_uint32_weird_endian.should == 0xde00faca
    end
  end
end
