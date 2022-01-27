require "test_helper"

class RfasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rfa = rfas(:one)
  end

  test "should get index" do
    get rfas_url
    assert_response :success
  end

  test "should get new" do
    get new_rfa_url
    assert_response :success
  end

  test "should create rfa" do
    assert_difference("Rfa.count") do
      post rfas_url, params: { rfa: {  } }
    end

    assert_redirected_to rfa_url(Rfa.last)
  end

  test "should show rfa" do
    get rfa_url(@rfa)
    assert_response :success
  end

  test "should get edit" do
    get edit_rfa_url(@rfa)
    assert_response :success
  end

  test "should update rfa" do
    patch rfa_url(@rfa), params: { rfa: {  } }
    assert_redirected_to rfa_url(@rfa)
  end

  test "should destroy rfa" do
    assert_difference("Rfa.count", -1) do
      delete rfa_url(@rfa)
    end

    assert_redirected_to rfas_url
  end
end
