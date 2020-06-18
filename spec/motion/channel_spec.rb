# frozen_string_literal: true

RSpec.describe Motion::Channel, type: :channel do
  class Component < ViewComponent::Base
    include Motion::Component

    attr_reader :count

    def initialize(connected: :noop, disconnected: :noop, count: 0)
      @connected = connected
      @disconnected = disconnected

      @count = count
    end

    def call
      content_tag(:div) { "The state has been changed #{@count} times." }
    end

    def connected
      public_send(@connected)
    end

    def disconnected
      public_send(@disconnected)
    end

    stream_from "noop", :noop
    map_motion :noop

    def noop(*)
    end

    stream_from "change_state", :change_state
    map_motion :change_state

    def change_state(*)
      @count += 1
    end

    stream_from "force_rerender", :force_rerender
    map_motion :force_rerender

    def force_rerender(*)
      rerender!
    end

    stream_from "setup_dynamic_motion", :setup_dynamic_motion
    map_motion :setup_dynamic_motion

    def setup_dynamic_motion(*)
      map_motion SecureRandom.hex, :noop
    end

    stream_from "setup_dynamic_stream", :setup_dynamic_stream
    map_motion :setup_dynamic_stream

    def setup_dynamic_stream(*)
      stream_from SecureRandom.hex, :noop
    end
  end

  let(:component) { Component.new }
  let(:state) { Motion.serializer.serialize(component).last }
  let(:version) { Motion::VERSION }

  describe "#subscribed" do
    subject { subscribe(state: state, version: version) }

    shared_examples "succesfully mounted" do |render:|
      it "accepts the subscription" do
        subject
        expect(subscription).to be_confirmed
      end

      it "streams from all of the component's broadcasts" do
        subject
        expect(subscription.streams).to include(*component.broadcasts)
      end

      it "runs the component's `connected` callback" do
        expect_any_instance_of(Component).to receive(:connected)
        subject
      end

      if render
        it "renders the component" do
          subject
          expect(transmissions.count).to eq(1)
        end
      else
        it "does *not* render the component" do
          subject
          expect(transmissions.count).to eq(0)
        end
      end
    end

    shared_examples "failed to mount" do
      it "rejects the subscription" do
        subject
        expect(subscription).to be_rejected
      end
    end

    context "when the client version is not supported" do
      let(:version) { "invalid" }
      it_behaves_like "failed to mount"
    end

    context "when the initial state is invalid" do
      let(:state) { "invalid" }
      it_behaves_like "failed to mount"
    end

    context "with a connected callback that does nothing" do
      let(:component) { Component.new(connected: :noop) }
      it_behaves_like "succesfully mounted", render: false
    end

    context "with a connected callback that changes state" do
      let(:component) { Component.new(connected: :change_state) }
      it_behaves_like "succesfully mounted", render: true
    end

    context "with a connected callback that forces rerender" do
      let(:component) { Component.new(connected: :force_rerender) }
      it_behaves_like "succesfully mounted", render: true
    end

    context "with a connected callback that maps a motion" do
      let(:component) { Component.new(connected: :setup_dynamic_motion) }
      it_behaves_like "succesfully mounted", render: true
    end

    context "with a connected callback that streams" do
      let(:component) { Component.new(connected: :setup_dynamic_stream) }
      it_behaves_like "succesfully mounted", render: true
    end
  end

  describe "#unsubscribed" do
    subject { unsubscribe }

    before(:each) { subscribe(state: state, version: version) }

    shared_examples "dismounted" do
      it "runs the component's `disconnected` callback" do
        expect_any_instance_of(Component).to receive(:disconnected)
        subject
      end

      it "does *not* render the component" do
        subject
        expect(transmissions.count).to eq(0)
      end
    end

    context "with a disconnected callback that does nothing" do
      let(:component) { Component.new(disconnected: :noop) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that changes state" do
      let(:component) { Component.new(disconnected: :change_state) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that forces rerender" do
      let(:component) { Component.new(disconnected: :force_rerender) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that maps a motion" do
      let(:component) { Component.new(disconnected: :setup_dynamic_motion) }
      it_behaves_like "dismounted"
    end

    context "with a disconnected callback that streams" do
      let(:component) { Component.new(disconnected: :setup_dynamic_stream) }
      it_behaves_like "dismounted"
    end
  end

  shared_examples "succesfully processed" do |render:|
    it "streams from all of the component's broadcasts" do
      subject
      expect(subscription.streams).to include(*component.broadcasts)
    end

    if render
      it "renders the component" do
        subject
        expect(transmissions.count).to eq(1)
      end
    else
      it "does *not* render the component" do
        subject
        expect(transmissions.count).to eq(0)
      end
    end
  end

  describe "#process_motion" do
    subject { perform :process_motion, name: motion, event: raw_event }

    before(:each) { subscribe(state: state, version: version) }

    let(:raw_event) { {} }

    context "with a handler that does nothing" do
      let(:motion) { "noop" }
      it_behaves_like "succesfully processed", render: false
    end

    context "with a handler that changes state" do
      let(:motion) { "change_state" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that forces rerender" do
      let(:motion) { "force_rerender" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that maps a motion" do
      let(:motion) { "setup_dynamic_motion" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that streams" do
      let(:motion) { "setup_dynamic_stream" }
      it_behaves_like "succesfully processed", render: true
    end
  end

  describe "#process_broadcast" do
    # TODO: Sadly, there does not seem to be testing infrustructure for using
    # broadcasts.
    subject { subscription.send(:process_broadcast, stream, message) }

    before(:each) { subscribe(state: state, version: version) }

    let(:message) { SecureRandom.hex }

    context "with a handler that does nothing" do
      let(:stream) { "noop" }
      it_behaves_like "succesfully processed", render: false
    end

    context "with a handler that changes state" do
      let(:stream) { "change_state" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that forces rerender" do
      let(:stream) { "force_rerender" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that maps a motion" do
      let(:stream) { "setup_dynamic_motion" }
      it_behaves_like "succesfully processed", render: true
    end

    context "with a handler that streams" do
      let(:stream) { "setup_dynamic_stream" }
      it_behaves_like "succesfully processed", render: true
    end
  end
end
