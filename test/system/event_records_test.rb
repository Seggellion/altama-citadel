require "application_system_test_case"

class EventRecordsTest < ApplicationSystemTestCase
  setup do
    @event_record = event_records(:one)
  end

  test "visiting the index" do
    visit event_records_url
    assert_selector "h1", text: "Event records"
  end

  test "should create event record" do
    visit event_records_url
    click_on "New event record"

    fill_in "Control point", with: @event_record.control_point
    fill_in "Duration", with: @event_record.duration
    fill_in "End time", with: @event_record.end_time
    fill_in "Event", with: @event_record.event_id
    fill_in "Event type", with: @event_record.event_type
    fill_in "Points", with: @event_record.points
    fill_in "Rank placement", with: @event_record.rank_placement
    fill_in "Start time", with: @event_record.start_time
    fill_in "Team", with: @event_record.team_id
    click_on "Create Event record"

    assert_text "Event record was successfully created"
    click_on "Back"
  end

  test "should update Event record" do
    visit event_record_url(@event_record)
    click_on "Edit this event record", match: :first

    fill_in "Control point", with: @event_record.control_point
    fill_in "Duration", with: @event_record.duration
    fill_in "End time", with: @event_record.end_time
    fill_in "Event", with: @event_record.event_id
    fill_in "Event type", with: @event_record.event_type
    fill_in "Points", with: @event_record.points
    fill_in "Rank placement", with: @event_record.rank_placement
    fill_in "Start time", with: @event_record.start_time
    fill_in "Team", with: @event_record.team_id
    click_on "Update Event record"

    assert_text "Event record was successfully updated"
    click_on "Back"
  end

  test "should destroy Event record" do
    visit event_record_url(@event_record)
    click_on "Destroy this event record", match: :first

    assert_text "Event record was successfully destroyed"
  end
end
