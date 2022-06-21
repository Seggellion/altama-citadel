require "application_system_test_case"

class NonConfidencesTest < ApplicationSystemTestCase
  setup do
    @non_confidence = non_confidences(:one)
  end

  test "visiting the index" do
    visit non_confidences_url
    assert_selector "h1", text: "Non confidences"
  end

  test "should create non confidence" do
    visit non_confidences_url
    click_on "New non confidence"

    click_on "Create Non confidence"

    assert_text "Non confidence was successfully created"
    click_on "Back"
  end

  test "should update Non confidence" do
    visit non_confidence_url(@non_confidence)
    click_on "Edit this non confidence", match: :first

    click_on "Update Non confidence"

    assert_text "Non confidence was successfully updated"
    click_on "Back"
  end

  test "should destroy Non confidence" do
    visit non_confidence_url(@non_confidence)
    click_on "Destroy this non confidence", match: :first

    assert_text "Non confidence was successfully destroyed"
  end
end
