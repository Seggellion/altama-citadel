require "application_system_test_case"

class TeamsTest < ApplicationSystemTestCase
  setup do
    @team = teams(:one)
  end

  test "visiting the index" do
    visit teams_url
    assert_selector "h1", text: "Teams"
  end

  test "should create team" do
    visit teams_url
    click_on "New team"

    fill_in "Description", with: @team.description
    fill_in "Fame", with: @team.fame
    fill_in "Karma", with: @team.karma
    fill_in "Team name", with: @team.team_name
    fill_in "Team owner", with: @team.owner_id
    fill_in "Website", with: @team.website
    click_on "Create Team"

    assert_text "Team was successfully created"
    click_on "Back"
  end

  test "should update Team" do
    visit team_url(@team)
    click_on "Edit this team", match: :first

    fill_in "Description", with: @team.description
    fill_in "Fame", with: @team.fame
    fill_in "Karma", with: @team.karma
    fill_in "Team name", with: @team.team_name
    fill_in "Team owner", with: @team.owner_id
    fill_in "Website", with: @team.website
    click_on "Update Team"

    assert_text "Team was successfully updated"
    click_on "Back"
  end

  test "should destroy Team" do
    visit team_url(@team)
    click_on "Destroy this team", match: :first

    assert_text "Team was successfully destroyed"
  end
end
