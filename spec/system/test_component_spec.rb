# frozen_string_literal: true

RSpec.describe TestComponent, type: :system do
  before(:each) { visit "/test_component" }

  it "processes actions" do
    expect(page).to have_text("The state has been changed 0 times.")
    click_button "change_state"
    expect(page).to have_text("The state has been changed 1 times.")
  end

  it "processes broadcasts" do
    expect(page).to have_text("The state has been changed 0 times.")
    ActionCable.server.broadcast "change_state", "message"
    expect(page).to have_text("The state has been changed 1 times.")
  end

  it "gracefully handles exceptions while processing broadcasts" do
    expect(page).to have_text("The state has been changed 0 times.")
    ActionCable.server.broadcast "raise_exception", "message"
    expect(page).to have_text("The state has been changed 0 times.")
  end
end
