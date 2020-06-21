# frozen_string_literal: true

RSpec.describe TestComponent, type: :system do
  before(:each) { visit(test_component_path) }

  scenario "Triggering a state change with user input causes a render" do
    expect(page).to have_text("The state has been changed 0 times.")

    click_button "change_state"

    expect(page).to have_text("The state has been changed 1 times.")
  end

  scenario "Triggering a state change with broadcasts causes a render" do
    expect(page).to have_text("The state has been changed 0 times.")

    ActionCable.server.broadcast "change_state", "message"

    expect(page).to have_text("The state has been changed 1 times.")
  end

  scenario "A catastrophic error in the component does not break the app" do
    expect(page).to have_text("The state has been changed 0 times.")

    expect(Rails.logger).to(
      receive(:error).with(/Exception from TestComponent/)
    )

    expect { ActionCable.server.broadcast "raise_exception", "message" }
      .not_to(raise_exception)

    expect(page).to have_text("The state has been changed 0 times.")
  end
end
