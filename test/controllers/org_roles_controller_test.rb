require "test_helper"

class OrgRolesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @org_role = org_roles(:one)
  end

  test "should get index" do
    get org_roles_url
    assert_response :success
  end

  test "should get new" do
    get new_org_role_url
    assert_response :success
  end

  test "should create org_role" do
    assert_difference("OrgRole.count") do
      post org_roles_url, params: { org_role: { description: @org_role.description, guildstone_id: @org_role.guildstone_id, org_role_owner: @org_role.org_role_owner } }
    end

    assert_redirected_to org_role_url(OrgRole.last)
  end

  test "should show org_role" do
    get org_role_url(@org_role)
    assert_response :success
  end

  test "should get edit" do
    get edit_org_role_url(@org_role)
    assert_response :success
  end

  test "should update org_role" do
    patch org_role_url(@org_role), params: { org_role: { description: @org_role.description, guildstone_id: @org_role.guildstone_id, org_role_owner: @org_role.org_role_owner } }
    assert_redirected_to org_role_url(@org_role)
  end

  test "should destroy org_role" do
    assert_difference("OrgRole.count", -1) do
      delete org_role_url(@org_role)
    end

    assert_redirected_to org_roles_url
  end
end
