require "application_system_test_case"

class UsershipsTest < ApplicationSystemTestCase
  setup do
    @usership = userships(:one)
  end

  test "visiting the index" do
    visit userships_url
    assert_selector "h1", text: "Userships"
  end

  test "should create usership" do
    visit userships_url
    click_on "New usership"

    fill_in "Description", with: @usership.description
    fill_in "Paint", with: @usership.paint
    fill_in "Ship", with: @usership.ship_id
    fill_in "Ship name", with: @usership.ship_name
    fill_in "User", with: @usership.user_id
    fill_in "Year purchased", with: @usership.year_purchased
    click_on "Create Usership"

    assert_text "Usership was successfully created"
    click_on "Back"
  end

  test "should update Usership" do
    visit usership_url(@usership)
    click_on "Edit this usership", match: :first

    fill_in "Description", with: @usership.description
    fill_in "Paint", with: @usership.paint
    fill_in "Ship", with: @usership.ship_id
    fill_in "Ship name", with: @usership.ship_name
    fill_in "User", with: @usership.user_id
    fill_in "Year purchased", with: @usership.year_purchased
    click_on "Update Usership"

    assert_text "Usership was successfully updated"
    click_on "Back"
  end

  test "should destroy Usership" do
    visit usership_url(@usership)
    click_on "Destroy this usership", match: :first

    assert_text "Usership was successfully destroyed"
  end
end
