# frozen_string_literal: true

RSpec.describe Motion::Element do
  describe ".from_raw" do
    subject { described_class.from_raw(input) }

    context "when the input is nil" do
      let(:input) { nil }

      it { is_expected.to be_nil }
    end

    context "when the input is a hash" do
      let(:input) { {"tagName" => "INPUT"} }

      it { is_expected.to be_a(described_class) }

      it "wraps it" do
        expect(subject.raw).to eq(input)
      end
    end
  end

  subject(:element) { described_class.new(raw) }

  context "in a particular case" do
    let(:raw) do
      {
        "tagName" => "INPUT",
        "value" => "test",
        "checked" => false,
        "attributes" => {
          "class" => "form-control",
          "data-field" => "name",
          "data-magic-field" => "pony",
          "type" => "text",
          "name" => "sign_up[name]",
          "id" => "sign_up_name"
        },
        "formData" => "sign_up%5Bname%5D=test"
      }
    end

    describe "#tag_name" do
      subject { element.tag_name }

      it { is_expected.to eq("INPUT") }
    end

    describe "#value" do
      subject { element.value }

      it { is_expected.to eq("test") }
    end

    describe "#checked?" do
      subject { element.checked? }

      it { is_expected.to eq(false) }
    end

    describe "#attributes" do
      subject { element.attributes }

      it do
        is_expected.to(
          eq(
            "class" => "form-control",
            "data-field" => "name",
            "data-magic-field" => "pony",
            "type" => "text",
            "name" => "sign_up[name]",
            "id" => "sign_up_name"
          )
        )
      end
    end

    describe "#[]" do
      subject { element[key] }

      context "with a string key exactly matching the data" do
        let(:key) { "class" }

        it { is_expected.to eq("form-control") }
      end

      context "with a symbol key in underscore case" do
        let(:key) { :data_field }

        it { is_expected.to eq("name") }
      end
    end

    describe "#id" do
      subject { element.id }

      it { is_expected.to eq("sign_up_name") }
    end

    describe "#data" do
      subject { element.data[key] }

      context "with a string key exactly matching the data" do
        let(:key) { "magic-field" }

        it { is_expected.to eq("pony") }
      end

      context "with a symbol key in underscore case" do
        let(:key) { :magic_field }

        it { is_expected.to eq("pony") }
      end
    end

    describe "#form_data" do
      subject { element.form_data }

      it { is_expected.to eq({"sign_up" => {"name" => "test"}}) }
    end
  end
end
