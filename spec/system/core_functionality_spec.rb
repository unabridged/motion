# frozen_string_literal: true

RSpec.describe "Core Functionality", type: :system do
  scenario "Triggering a state change with user input causes a render" do
    visit(test_component_path)

    expect(page).to have_text("The state has been changed 0 times.")

    click_button "change_state"

    expect(page).to have_text("The state has been changed 1 times.")
  end

  scenario "Triggering a state change with broadcasts causes a render" do
    visit(test_component_path)

    expect(page).to have_text("The state has been changed 0 times.")

    ActionCable.server.broadcast "change_state", "message"

    expect(page).to have_text("The state has been changed 1 times.")
  end

  scenario "A catastrophic error in the component does not break the app" do
    visit(test_component_path)

    expect(page).to have_text("The state has been changed 0 times.")

    expect(Rails.logger).to(
      receive(:error).with(/Exception from TestComponent/)
    )

    expect { ActionCable.server.broadcast "raise_exception", "message" }
      .not_to(raise_exception)

    expect(page).to have_text("The state has been changed 0 times.")
  end

  scenario "Nested state is preserved when an outer component renders" do
    visit(counter_component_path)

    click_button "+"
    click_button "+"

    expect(find('.count')).to have_text('2')

    click_button "Build Child"

    expect(find('.parent .count')).to have_text('2')
    expect(find('.child .count')).to have_text('2')

    within ".parent" do
      click_button "+"
    end

    within ".child" do
      click_button "-"
    end

    expect(find('.parent .count')).to have_text('3')
    expect(find('.child .count')).to have_text('1')

    within ".parent" do
      click_button "Clear Child"
    end

    expect(find('.count')).to have_text('3')

    click_button "Build Child"

    expect(find('.parent .count')).to have_text('3')
    expect(find('.child .count')).to have_text('3')
  end
end
