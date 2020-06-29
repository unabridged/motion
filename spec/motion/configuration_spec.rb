# frozen_string_literal: true

RSpec.describe Motion::Configuration do
  describe "the default configuration" do
    subject(:default) { described_class.new }

    before(:each) do
      expect_any_instance_of(described_class).to(
        receive(:warn).with(/Motion is automatically inferring/)
      )

      expect_any_instance_of(described_class).to(
        receive(:`).with("git rev-parse HEAD").and_return(revision_from_git)
      )
    end

    let(:revision_from_git) { "revision-hash" }

    describe "#secret" do
      subject { default.secret }

      it "derives some entropy from the application secret" do
        expect(subject).to(
          eq(Rails.application.key_generator.generate_key("motion:secret"))
        )
      end
    end

    describe "#revision" do
      subject { default.revision }

      it { is_expected.to eq(revision_from_git) }
    end

    describe "#renderer_for_connection_proc" do
      subject { default.renderer_for_connection_proc.call(connection) }

      let(:connection) { double(ApplicationCable::Connection, env: env) }

      let(:env) do
        {
          Rack::RACK_SESSION => session,
          Rack::HTTP_COOKIE => cookie
        }
      end

      let(:cookie) { cookies.map { |key, value| "#{key}=#{value}" }.join("&") }

      let(:session) { {"foo" => "bar"} }
      let(:cookies) { {"bar" => "baz"} }

      it "builds a renderer from the ApplicationController" do
        expect(subject.controller).to eq(ApplicationController)
      end

      it "builds a render which has access to the session" do
        expect(subject.render(inline: "<%= session['foo'] %>")).to(
          eq(session["foo"])
        )
      end

      it "builds a render which has access to the cookies" do
        expect(subject.render(inline: "<%= cookies['bar'] %>")).to(
          eq(cookies["bar"])
        )
      end

      context "when no ApplicationController is defined" do
        before(:each) { hide_const("ApplicationController") }

        it "builds a renderer from ActionController::Base" do
          expect(subject.controller).to eq(ActionController::Base)
        end
      end
    end

    describe "#key_attribute" do
      subject { default.key_attribute }

      it { is_expected.to eq("data-motion-key") }
    end

    describe "#state_attribute" do
      subject { default.state_attribute }

      it { is_expected.to eq("data-motion-state") }
    end

    describe "#motion_attribute" do
      subject { default.motion_attribute }

      it { is_expected.to eq("data-motion") }
    end
  end

  it "allows options to be set within the initalization block" do
    config =
      described_class.new { |c|
        c.revision = "value"
      }

    expect(config.revision).to eq("value")
  end

  it "does not allow options to be set after initalization" do
    config =
      described_class.new { |c|
        c.revision = "value"
      }

    expect { config.revision = "new value" }.to(
      raise_error(Motion::AlreadyConfiguredError)
    )
  end
end
