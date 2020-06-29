# frozen_string_literal: true

RSpec.describe Motion::Generators::InstallGenerator, type: :generator do
  before(:each) do
    # Ensure an application pack exists
    pack_path = File.join(destination_root, "app/javascript/packs")
    FileUtils.mkdir_p(pack_path)
    FileUtils.touch(File.join(pack_path, "application.js"))

    run_generator
  end

  it "is accessible via `motion:install`" do
    expect(generator_class.banner).to include("rails generate motion:install")
  end

  it "creates the Ruby initializer" do
    assert_file "config/initializers/motion.rb"
  end

  it "creates the JavaScript initializer" do
    assert_file "app/javascript/motion.js"
  end

  it "imports the Motion client into the application's bundle" do
    assert_file "app/javascript/packs/application.js", /import "motion"/
  end
end
