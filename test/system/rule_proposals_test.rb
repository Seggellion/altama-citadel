require "application_system_test_case"

class RuleProposalsTest < ApplicationSystemTestCase
  setup do
    @rule_proposal = rule_proposals(:one)
  end

  test "visiting the index" do
    visit rule_proposals_url
    assert_selector "h1", text: "Rule proposals"
  end

  test "should create rule proposal" do
    visit rule_proposals_url
    click_on "New rule proposal"

    click_on "Create Rule proposal"

    assert_text "Rule proposal was successfully created"
    click_on "Back"
  end

  test "should update Rule proposal" do
    visit rule_proposal_url(@rule_proposal)
    click_on "Edit this rule proposal", match: :first

    click_on "Update Rule proposal"

    assert_text "Rule proposal was successfully updated"
    click_on "Back"
  end

  test "should destroy Rule proposal" do
    visit rule_proposal_url(@rule_proposal)
    click_on "Destroy this rule proposal", match: :first

    assert_text "Rule proposal was successfully destroyed"
  end
end
