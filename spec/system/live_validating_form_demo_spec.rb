# frozen_string_literal: true

RSpec.describe "Live Validating Form Demo", type: :system do
  before(:each) { visit(new_dog_path) }

  # https://bloggie.io/@kinopyo/capybara-trigger-blur-event
  def blur
    find("body").click
  end

  it "works like a normal form" do
    fill_in "dog_name", with: "Fido"
    click_button "Create Dog"

    expect(Dog.find_by(name: "Fido")).to be_present
  end

  it "automatically validates after user input" do
    Dog.create!(name: "Taken")

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
