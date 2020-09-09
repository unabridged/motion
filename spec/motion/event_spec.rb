# frozen_string_literal: true

RSpec.describe Motion::Event do
  describe ".from_raw" do
    subject { described_class.from_raw(input) }

    context "when the input is nil" do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end

    context "when the input is a hash" do
      let(:input) { {"type" => "click"} }

      it { is_expected.to be_a(described_class) }

      it "wraps it" do
        expect(subject.raw).to eq(input)
      end
    end
  end

  subject(:event) { described_class.new(raw) }

  context "in a particular case" do
    let(:raw) do
      {
        "type" => "click",
        "details" => {
          "x" => "1",
          "y" => "7"
        },
        "extraData" => nil,
        "target" => {
          "tagName" => "INPUT",
          "value" => "test",
          "attributes" => {
            "class" => "form-control",
            "data-field" => "name",
            "type" => "text",
            "name" => "sign_up[name]",
            "id" => "sign_up_name"
          },
          "formData" => "sign_up%5Bname%5D=test"
        },
        "element" => {
          "tagName" => "INPUT",
          "value" => "test",
          "attributes" => {
            "class" => "form-control",
            "data-field" => "name",
            "type" => "text",
            "name" => "sign_up[name]",
            "id" => "sign_up_name"
          },
          "formData" => "sign_up%5Bname%5D=test"
        }
      }
    end

    describe "#type" do
      subject { event.type }

      it { is_expected.to eq("click") }
    end

    describe "#name" do
      subject { event.name }

      it { is_expected.to eq("click") }
    end

    describe "#details" do
      subject { event.details }

      it { is_expected.to eq("x" => "1", "y" => "7") }
    end

    describe "#extra_data" do
      subject { event.extra_data }

      it { is_expected.to be_nil }
    end

    describe "#target" do
      subject { event.target }

      it { is_expected.to be_a(Motion::Element) }

      it "has raw data from the underlying event" do
        expect(subject.raw).to eq(raw["target"])
      end
    end

    describe "#element" do
      subject { event.element }

      it { is_expected.to be_a(Motion::Element) }

      it "has raw data from the underlying event" do
        expect(subject.raw).to eq(raw["element"])
      end
    end

    describe "#form_data" do
      subject { event.form_data }

      it { is_expected.to eq({"sign_up" => {"name" => "test"}}) }
    end
  end
end
