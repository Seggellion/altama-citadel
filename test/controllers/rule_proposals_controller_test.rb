require "test_helper"

class RuleProposalsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rule_proposal = rule_proposals(:one)
  end

  test "should get index" do
    get rule_proposals_url
    assert_response :success
  end

  test "should get new" do
    get new_rule_proposal_url
    assert_response :success
  end

  test "should create rule_proposal" do
    assert_difference("RuleProposal.count") do
      post rule_proposals_url, params: { rule_proposal: {  } }
    end

    assert_redirected_to rule_proposal_url(RuleProposal.last)
  end

  test "should show rule_proposal" do
    get rule_proposal_url(@rule_proposal)
    assert_response :success
  end

  test "should get edit" do
    get edit_rule_proposal_url(@rule_proposal)
    assert_response :success
  end

  test "should update rule_proposal" do
    patch rule_proposal_url(@rule_proposal), params: { rule_proposal: {  } }
    assert_redirected_to rule_proposal_url(@rule_proposal)
  end

  test "should destroy rule_proposal" do
    assert_difference("RuleProposal.count", -1) do
      delete rule_proposal_url(@rule_proposal)
    end

    assert_redirected_to rule_proposals_url
  end
end
