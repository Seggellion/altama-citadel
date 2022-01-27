require "test_helper"

class EventRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @event_record = event_records(:one)
  end

  test "should get index" do
    get event_records_url
    assert_response :success
  end

  test "should get new" do
    get new_event_record_url
    assert_response :success
  end

  test "should create event_record" do
    assert_difference("EventRecord.count") do
      post event_records_url, params: { event_record: { control_point: @event_record.control_point, duration: @event_record.duration, end_time: @event_record.end_time, event_id: @event_record.event_id, event_type: @event_record.event_type, points: @event_record.points, rank_placement: @event_record.rank_placement, start_time: @event_record.start_time, team_id: @event_record.team_id } }
    end

    assert_redirected_to event_record_url(EventRecord.last)
  end

  test "should show event_record" do
    get event_record_url(@event_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_event_record_url(@event_record)
    assert_response :success
  end

  test "should update event_record" do
    patch event_record_url(@event_record), params: { event_record: { control_point: @event_record.control_point, duration: @event_record.duration, end_time: @event_record.end_time, event_id: @event_record.event_id, event_type: @event_record.event_type, points: @event_record.points, rank_placement: @event_record.rank_placement, start_time: @event_record.start_time, team_id: @event_record.team_id } }
    assert_redirected_to event_record_url(@event_record)
  end

  test "should destroy event_record" do
    assert_difference("EventRecord.count", -1) do
      delete event_record_url(@event_record)
    end

    assert_redirected_to event_records_url
  end
end
