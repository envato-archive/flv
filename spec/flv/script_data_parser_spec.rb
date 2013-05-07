require "flv/script_data_parser"

describe FLV::ScriptDataParser do
  let(:parser) { FLV::ScriptDataParser.new(@str) }
  let(:value)  { parser.parse_single_value }

  context "numbers" do
    it "parses the number as a big endian double precision float" do
      @str = "\x00@^\xDD/\x1A\x9F\xBEw"
      value.should == 123.456
    end
  end

  context "booleans" do
    it "parses a 0 byte as false" do
      @str = "\x01\x00"
      value.should == false
    end

    it "parses a 1 byte as true" do
      @str = "\x01\x01"
      value.should == true
    end
  end

  context "strings" do
    it "parses empty strings" do
      @str = "\x02\x00\x00"
      value.should == ""
    end

    it "parses strings < 255 chars" do
      @str = "\x02\x00\x0bhello world"
      value.should == "hello world"
    end

    it "parses strings > 255 chars (where endianness matters)" do
      @str = "\x02\x02\x00#{"x"*512}"
      value.should == "x" * 512
    end
  end

  context "objects" do
    it "parses empty objects" do
      @str = "\x03\x00\x00\x09"
      value.should == {}
    end

    it "parses objects as pairs of a 'string value' and a value" do
      @str = "\x03\x02\x00\x04name\x02\x00\x05value\x00\x00\x09"
      value.should == { "name" => "value" }
    end
  end

  context "arrays" do
    it "parses empty 'arrays' as empty hashes" do
      @str = "\x08\x00\x00\x00\x00\x00\x00\x09"
      value.should == {}
    end

    it "ignores the length hint" do
      @str = "\x08\x11\x22\x33\x44\x00\x00\x09"
      value.should == {}
    end

    it "parses arrays as pairs of a non-value string and a value" do
      @str = "\x08\x00\x00\x00\x00\x00\x04name\x02\x00\x05value\x00\x00\x09"
      value.should == { "name" => "value" }
    end
  end

  context "dates" do
    it "can parse an empty date" do
      @str = "\x0b\0\0\0\0\0\0\0\0\0\0"
      value.should == Time.utc(1970, 1, 1, 0, 0, 0)
    end

    it "can parse an empty date in UTC+10" do
      @str = "\x0b\0\0\0\0\0\0\0\0\x02X"
      value.should == Time.new(1970, 1, 1, 0, 0, 0, 10 * 3600)
    end

    it "can parse today in UTC+10" do
      @str = "\x0bA\xD4bB\xDE\x80\0\0\x02X"
      value.should == Time.new(2013, 5, 7, 14, 11, 6, 10 * 3600)
    end

    it "can parse today in UTC-10" do
      @str = "\x0bA\xD4bB\xDE\x80\0\0\xfd\xa8"
      value.should == Time.new(2013, 5, 7, 14, 11, 6, -10 * 3600)
    end
  end
end
