require "application_system_test_case"

class ManufacturersTest < ApplicationSystemTestCase
  setup do
    @manufacturer = manufacturers(:one)
  end

  test "visiting the index" do
    visit manufacturers_url
    assert_selector "h1", text: "Manufacturers"
  end

  test "should create manufacturer" do
    visit manufacturers_url
    click_on "New manufacturer"

    fill_in "Description", with: @manufacturer.description
    fill_in "Name", with: @manufacturer.name
    fill_in "Origin location", with: @manufacturer.origin_location
    click_on "Create Manufacturer"

    assert_text "Manufacturer was successfully created"
    click_on "Back"
  end

  test "should update Manufacturer" do
    visit manufacturer_url(@manufacturer)
    click_on "Edit this manufacturer", match: :first

    fill_in "Description", with: @manufacturer.description
    fill_in "Name", with: @manufacturer.name
    fill_in "Origin location", with: @manufacturer.origin_location
    click_on "Update Manufacturer"

    assert_text "Manufacturer was successfully updated"
    click_on "Back"
  end

  test "should destroy Manufacturer" do
    visit manufacturer_url(@manufacturer)
    click_on "Destroy this manufacturer", match: :first

    assert_text "Manufacturer was successfully destroyed"
  end
end
