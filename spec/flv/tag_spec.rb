# coding: BINARY

require "flv/tag"
require "stringio"

describe FLV::Tag do
  describe ".read" do
    let(:io) { StringIO.new(string) }

    context "reading a metadata tag" do
      let(:string) { "\x12" }

      it "creates a FLV::Tag::Data" do
        FLV::Tag::Data.should_receive(:new).with(io)
        FLV::Tag.read(io)
      end
    end

    context "reading an audio tag" do
      let(:string) { "\x08" }

      it "creates a FLV::Tag::Data" do
        FLV::Tag::Audio.should_receive(:new).with(io)
        FLV::Tag.read(io)
      end
    end

    context "reading a video tag" do
      let(:string) { "\x09" }

      it "creates a FLV::Tag::Data" do
        FLV::Tag::Video.should_receive(:new).with(io)
        FLV::Tag.read(io)
      end
    end
  end

  describe "tag parsing" do
    let(:string) { "\x00\x00\x0b\xad\xbe\xef\xde\x00\x00\x00hello world\x00\x00\x00\x15" }
    subject { FLV::Tag.new(StringIO.new(string)) }

    its(:length)    { should == 11 }
    its(:timestamp) { should == 0xdeadbeef }
    its(:raw_data)  { should == "hello world" }
    its(:footer)    { should == 21 }
  end
end
