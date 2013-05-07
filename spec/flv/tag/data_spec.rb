require "flv/tag/data"

describe FLV::Tag::Data do
  context "integration test" do
    let(:preview_flv) { File.open(File.expand_path("../../../files/preview.flv", __FILE__), "rb") }
    subject { FLV.new(preview_flv).each_tag.first }

    its(:duration)        { should == 6.0 }
    its(:width)           { should == 640 }
    its(:height)          { should == 360 }
    its(:video_data_rate) { should == 700 }
    its(:frame_rate)      { should == 30 }
    its(:video_codec_id)  { should == 4 }
    its(:audio_data_rate) { should == 128 }
    its(:audio_delay)     { should == 0.038 }
    its(:audio_codec_id)  { should == 2 }
    its(:seek_to_end?)    { should == true }
  end
end
