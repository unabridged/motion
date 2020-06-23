# frozen_string_literal: true

RSpec.describe Generators::Motion::InstallGenerator, type: :generator do
  before(:each) { run_generator }

  it "is accessible via `motion:install`" do
    expect(generator_class.banner).to include("motion:install")
  end

  it "creates the initializer" do
    assert_file "config/initializers/motion.rb"
  end

  it "creates the Stimulus controller" do
    assert_file "app/javascript/controllers/motion_controller.js"
  end
end
