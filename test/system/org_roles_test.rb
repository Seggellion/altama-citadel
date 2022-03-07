require "application_system_test_case"

class OrgRolesTest < ApplicationSystemTestCase
  setup do
    @org_role = org_roles(:one)
  end

  test "visiting the index" do
    visit org_roles_url
    assert_selector "h1", text: "Org roles"
  end

  test "should create org role" do
    visit org_roles_url
    click_on "New org role"

    fill_in "Description", with: @org_role.description
    fill_in "Guildstone", with: @org_role.guildstone_id
    fill_in "Org role owner", with: @org_role.org_role_owner
    click_on "Create Org role"

    assert_text "Org role was successfully created"
    click_on "Back"
  end

  test "should update Org role" do
    visit org_role_url(@org_role)
    click_on "Edit this org role", match: :first

    fill_in "Description", with: @org_role.description
    fill_in "Guildstone", with: @org_role.guildstone_id
    fill_in "Org role owner", with: @org_role.org_role_owner
    click_on "Update Org role"

    assert_text "Org role was successfully updated"
    click_on "Back"
  end

  test "should destroy Org role" do
    visit org_role_url(@org_role)
    click_on "Destroy this org role", match: :first

    assert_text "Org role was successfully destroyed"
  end
end
