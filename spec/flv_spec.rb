require "flv"

describe FLV do
  context "integration test" do
    let(:preview_flv) { File.open(File.expand_path("../files/preview.flv", __FILE__), "rb") }
    subject { FLV.new(preview_flv) }

    its(:audio?) { should be_true }
    its(:video?) { should be_true }
  end

  describe "#audio? and #video?" do
    let(:flags) { 0 }
    subject { FLV.allocate.tap do |flv| flv.stub(:flags => flags) end }

    context "doesn't have any flags set" do
      its(:audio?) { should be_false }
      its(:video?) { should be_false }
    end

    context "has the audio flag set" do
      let(:flags) { FLV::AUDIO_FLAG }

      its(:audio?) { should be_true }
      its(:video?) { should be_false }
    end

    context "has the video flag set" do
      let(:flags) { FLV::VIDEO_FLAG }

      its(:audio?) { should be_false }
      its(:video?) { should be_true }
    end

    context "has the audio and video flags set" do
      let(:flags) { FLV::AUDIO_FLAG | FLV::VIDEO_FLAG }

      its(:audio?) { should be_true }
      its(:video?) { should be_true }
    end
  end
end
