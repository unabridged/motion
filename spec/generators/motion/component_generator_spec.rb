# frozen_string_literal: true

# TODO: This is super awkward, but it is the only way I could get the generator
# to run without having a full Rails app already installed into the destination
# directory.
Motion::Generators::ComponentGenerator.class_eval do
  protected

  def generate(generator, *args)
    return super unless generator == "component"

    require "rails/generators/component/component_generator"

    Rails::Generators::ComponentGenerator.start(
      args,
      destination_root: destination_root
    )
  end
end

RSpec.describe Motion::Generators::ComponentGenerator, type: :generator do
  before(:each) do
    run_generator
  end

  it "is accessible via `motion:component`" do
    expect(generator_class.banner).to include("rails generate motion:component")
  end

  context "with only a component name" do
    arguments %w[MagicComponent]

    it "creates a component that includes `Motion::Component`" do
      assert_file(
        "app/components/magic_component.rb",
        /include Motion::Component/
      )
    end
  end
end
