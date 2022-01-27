require "test_helper"

class EventTeamsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event_team = event_teams(:one)
  end

  test "should get index" do
    get event_teams_url
    assert_response :success
  end

  test "should get new" do
    get new_event_team_url
    assert_response :success
  end

  test "should create event_team" do
    assert_difference("EventTeam.count") do
      post event_teams_url, params: { event_team: { event_id: @event_team.event_id, team_id: @event_team.team_id } }
    end

    assert_redirected_to event_team_url(EventTeam.last)
  end

  test "should show event_team" do
    get event_team_url(@event_team)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_team_url(@event_team)
    assert_response :success
  end

  test "should update event_team" do
    patch event_team_url(@event_team), params: { event_team: { event_id: @event_team.event_id, team_id: @event_team.team_id } }
    assert_redirected_to event_team_url(@event_team)
  end

  test "should destroy event_team" do
    assert_difference("EventTeam.count", -1) do
      delete event_team_url(@event_team)
    end

    assert_redirected_to event_teams_url
  end
end
