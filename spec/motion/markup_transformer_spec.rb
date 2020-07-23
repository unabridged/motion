# frozen_string_literal: true

RSpec.describe Motion::MarkupTransformer do
  subject(:markup_transformer) do
    described_class.new(
      serializer: serializer,
      key_attribute: key_attribute,
      state_attribute: state_attribute
    )
  end

  let(:key_attribute) { SecureRandom.hex }
  let(:state_attribute) { SecureRandom.hex }

  let(:serializer) { double(Motion::Serializer, serialize: [key, state]) }
  let(:key) { SecureRandom.hex }
  let(:state) { SecureRandom.hex }
  let(:component) { Object.new }

  describe "#add_state_to_html" do
    subject { markup_transformer.add_state_to_html(component, html) }

    context "when the markup has a single root element" do
      let(:html) { "<div>content</div>" }

      it "transforms the markup to include the extra attributes" do
        expect(subject).to(
          eq(
            "<div " \
              "#{key_attribute}=\"#{key}\" " \
              "#{state_attribute}=\"#{state}\"" \
            ">" \
              "content" \
            "</div>"
          )
        )
      end
    end

    context "when the markup has multiple elements" do
      let(:html) { "<div></div><div></div>" }

      it "raises MultipleRootsError" do
        expect { subject }.to raise_error(Motion::Errors::MultipleRootsError)
      end
    end

    context "when there is a single root element with trailing whitespace" do
      let(:html) { "<div>content</div>\n\n" }

      it "preserves the whitespace around the element" do
        expect(subject).to(
          eq(
            "<div " \
              "#{key_attribute}=\"#{key}\" " \
              "#{state_attribute}=\"#{state}\"" \
            ">" \
              "content" \
            "</div>\n\n"
          )
        )
      end
    end

    context "when the component does not generate any markup" do
      let(:html) { "" }

      it { is_expected.to be_nil }
    end

    context "when the component generates only whitespace markup" do
      let(:html) { "" }

      it { is_expected.to be_nil }
    end
  end
end
