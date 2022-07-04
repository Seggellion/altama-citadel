require "test_helper"

class NonConfidencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @non_confidence = non_confidences(:one)
  end

  test "should get index" do
    get non_confidences_url
    assert_response :success
  end

  test "should get new" do
    get new_non_confidence_url
    assert_response :success
  end

  test "should create non_confidence" do
    assert_difference("NonConfidence.count") do
      post non_confidences_url, params: { non_confidence: {  } }
    end

    assert_redirected_to non_confidence_url(NonConfidence.last)
  end

  test "should show non_confidence" do
    get non_confidence_url(@non_confidence)
    assert_response :success
  end

  test "should get edit" do
    get edit_non_confidence_url(@non_confidence)
    assert_response :success
  end

  test "should update non_confidence" do
    patch non_confidence_url(@non_confidence), params: { non_confidence: {  } }
    assert_redirected_to non_confidence_url(@non_confidence)
  end

  test "should destroy non_confidence" do
    assert_difference("NonConfidence.count", -1) do
      delete non_confidence_url(@non_confidence)
    end

    assert_redirected_to non_confidences_url
  end
end
