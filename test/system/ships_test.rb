require "application_system_test_case"

class ShipsTest < ApplicationSystemTestCase
  setup do
    @ship = ships(:one)
  end

  test "visiting the index" do
    visit ships_url
    assert_selector "h1", text: "Ships"
  end

  test "should create ship" do
    visit ships_url
    click_on "New ship"

    fill_in "Beam", with: @ship.beam
    fill_in "Crew", with: @ship.crew
    fill_in "Fuel", with: @ship.fuel
    fill_in "Height", with: @ship.height
    fill_in "Length", with: @ship.length
    fill_in "Make", with: @ship.make_id
    fill_in "Model", with: @ship.model
    fill_in "Msrp", with: @ship.msrp
    fill_in "Quantum", with: @ship.quantum
    fill_in "Scu", with: @ship.scu
    fill_in "Weight", with: @ship.mass
    click_on "Create Ship"

    assert_text "Ship was successfully created"
    click_on "Back"
  end

  test "should update Ship" do
    visit ship_url(@ship)
    click_on "Edit this ship", match: :first

    fill_in "Beam", with: @ship.beam
    fill_in "Crew", with: @ship.crew
    fill_in "Fuel", with: @ship.fuel
    fill_in "Height", with: @ship.height
    fill_in "Length", with: @ship.length
    fill_in "Make", with: @ship.make_id
    fill_in "Model", with: @ship.model
    fill_in "Msrp", with: @ship.msrp
    fill_in "Quantum", with: @ship.quantum
    fill_in "Scu", with: @ship.scu
    fill_in "Weight", with: @ship.mass
    click_on "Update Ship"

    assert_text "Ship was successfully updated"
    click_on "Back"
  end

  test "should destroy Ship" do
    visit ship_url(@ship)
    click_on "Destroy this ship", match: :first

    assert_text "Ship was successfully destroyed"
  end
end
