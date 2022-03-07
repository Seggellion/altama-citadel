require "application_system_test_case"

class GuildstonesTest < ApplicationSystemTestCase
  setup do
    @guildstone = guildstones(:one)
  end

  test "visiting the index" do
    visit guildstones_url
    assert_selector "h1", text: "Guildstones"
  end

  test "should create guildstone" do
    visit guildstones_url
    click_on "New guildstone"

    fill_in "Charter", with: @guildstone.charter
    fill_in "Title", with: @guildstone.title
    click_on "Create Guildstone"

    assert_text "Guildstone was successfully created"
    click_on "Back"
  end

  test "should update Guildstone" do
    visit guildstone_url(@guildstone)
    click_on "Edit this guildstone", match: :first

    fill_in "Charter", with: @guildstone.charter
    fill_in "Title", with: @guildstone.title
    click_on "Update Guildstone"

    assert_text "Guildstone was successfully updated"
    click_on "Back"
  end

  test "should destroy Guildstone" do
    visit guildstone_url(@guildstone)
    click_on "Destroy this guildstone", match: :first

    assert_text "Guildstone was successfully destroyed"
  end
end
