require "application_system_test_case"

class EventTeamsTest < ApplicationSystemTestCase
  setup do
    @event_team = event_teams(:one)
  end

  test "visiting the index" do
    visit event_teams_url
    assert_selector "h1", text: "Event teams"
  end

  test "should create event team" do
    visit event_teams_url
    click_on "New event team"

    fill_in "Event", with: @event_team.event_id
    fill_in "Team", with: @event_team.team_id
    click_on "Create Event team"

    assert_text "Event team was successfully created"
    click_on "Back"
  end

  test "should update Event team" do
    visit event_team_url(@event_team)
    click_on "Edit this event team", match: :first

    fill_in "Event", with: @event_team.event_id
    fill_in "Team", with: @event_team.team_id
    click_on "Update Event team"

    assert_text "Event team was successfully updated"
    click_on "Back"
  end

  test "should destroy Event team" do
    visit event_team_url(@event_team)
    click_on "Destroy this event team", match: :first

    assert_text "Event team was successfully destroyed"
  end
end
