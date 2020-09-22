# frozen_string_literal: true

RSpec.describe "Core Functionality", type: :system do
  scenario "Triggering a state change with user input causes a render" do
    visit(test_component_path)
    wait_until_component_connected!

    expect(page).to have_text("The state has been changed 0 times.")

    click_button "change_state"

    expect(page).to have_text("The state has been changed 1 times.")
  end

  scenario "Triggering a state change with broadcasts causes a render" do
    visit(test_component_path)
    wait_until_component_connected!

    expect(page).to have_text("The state has been changed 0 times.")

    ActionCable.server.broadcast "change_state", "message"
    wait_until_component_rendered!

    expect(page).to have_text("The state has been changed 1 times.")
  end

  scenario "Nested state is preserved when an outer component renders" do
    visit(counter_component_path)
    wait_until_component_connected!

    click_button "+"
    click_button "+"

    expect(find(".count")).to have_text("2")

    click_button "Build Child"

    expect(find(".parent .count")).to have_text("2")
    expect(find(".child .count")).to have_text("2")

    within ".parent" do
      click_button "+"
    end

    within ".child" do
      click_button "-"
    end

    expect(find(".parent .count")).to have_text("3")
    expect(find(".child .count")).to have_text("1")

    within ".parent" do
      click_button "Clear Child"
    end

    expect(find(".count")).to have_text("3")

    click_button "Build Child"

    expect(find(".parent .count")).to have_text("3")
    expect(find(".child .count")).to have_text("3")
  end

  scenario "Periodic timers run and can be removed dynamically" do
    visit(timer_component_path)
    # wait_until_component_connected!

    expect(page).to have_text("1")
    sleep 1
    expect(page).to have_text("0")
    sleep 1
    expect(page).to have_text("0")
  end

  scenario "Callbacks can be passed to children and trigger on parents" do
    visit(callback_component_path)
    wait_until_component_connected!

    expect(page).to have_text("The count is 0")
    click_button "+"
    click_button "+"
    expect(page).to have_text("The count is 2")
  end
end
