require "application_system_test_case"

class RfasTest < ApplicationSystemTestCase
  setup do
    @rfa = rfas(:one)
  end

  test "visiting the index" do
    visit rfas_url
    assert_selector "h1", text: "Rfas"
  end

  test "should create rfa" do
    visit rfas_url
    click_on "New rfa"

    click_on "Create Rfa"

    assert_text "Rfa was successfully created"
    click_on "Back"
  end

  test "should update Rfa" do
    visit rfa_url(@rfa)
    click_on "Edit this rfa", match: :first

    click_on "Update Rfa"

    assert_text "Rfa was successfully updated"
    click_on "Back"
  end

  test "should destroy Rfa" do
    visit rfa_url(@rfa)
    click_on "Destroy this rfa", match: :first

    assert_text "Rfa was successfully destroyed"
  end
end
