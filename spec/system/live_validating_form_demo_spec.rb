# frozen_string_literal: true

RSpec.describe "Live Validating Form Demo", type: :system do
  before(:each) do
    visit(new_dog_path)
    wait_until_component_connected!
  end

  it "works like a normal form" do
    fill_in "dog_name", with: "Fido"
    click_button "Create Dog"

    expect(Dog.find_by(name: "Fido")).to be_present
  end

  it "automatically validates after user input" do
    Dog.create!(name: "Taken")
    wait_until_component_rendered!

    fill_in "dog_name", with: "Taken"
    blur

    expect(page).to have_text("taken")

    fill_in "dog_name", with: "Available"
    blur

    expect(page).not_to have_text("taken")
  end

  it "automatically validates when a new record is created elsewhere" do
    fill_in "dog_name", with: "Tibbles"
    blur

    expect(page).not_to have_text("taken")

    Dog.create!(name: "Tibbles")
    wait_until_component_rendered!

    expect(page).to have_text("taken")
  end

  it "works with nested attributes" do
    fill_in "dog_name", with: "Fido"

    click_button "Add Toy"

    find('[data-identifier-for-test-suite="toy-name[0]"]').fill_in(with: "Ball")

    expect(page).not_to have_text("can't be blank")

    click_button "Add Toy"

    find('[data-identifier-for-test-suite="toy-name[0]"]').fill_in(with: "")
    find('[data-identifier-for-test-suite="toy-name[1]"]').fill_in(with: "Ball")
    blur

    expect(page).to have_text("can't be blank")
  end
end
