require "test_helper"

class ShipsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ship = ships(:one)
  end

  test "should get index" do
    get ships_url
    assert_response :success
  end

  test "should get new" do
    get new_ship_url
    assert_response :success
  end

  test "should create ship" do
    assert_difference("Ship.count") do
      post ships_url, params: { ship: { beam: @ship.beam, crew: @ship.crew, fuel: @ship.fuel, height: @ship.height, length: @ship.length, make_id: @ship.make_id, model: @ship.model, msrp: @ship.msrp, quantum: @ship.quantum, scu: @ship.scu, weight: @ship.weight } }
    end

    assert_redirected_to ship_url(Ship.last)
  end

  test "should show ship" do
    get ship_url(@ship)
    assert_response :success
  end

  test "should get edit" do
    get edit_ship_url(@ship)
    assert_response :success
  end

  test "should update ship" do
    patch ship_url(@ship), params: { ship: { beam: @ship.beam, crew: @ship.crew, fuel: @ship.fuel, height: @ship.height, length: @ship.length, make_id: @ship.make_id, model: @ship.model, msrp: @ship.msrp, quantum: @ship.quantum, scu: @ship.scu, weight: @ship.weight } }
    assert_redirected_to ship_url(@ship)
  end

  test "should destroy ship" do
    assert_difference("Ship.count", -1) do
      delete ship_url(@ship)
    end

    assert_redirected_to ships_url
  end
end
