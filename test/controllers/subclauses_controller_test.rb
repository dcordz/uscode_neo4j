require 'test_helper'

class SubclausesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subclause = subclauses(:one)
  end

  test "should get index" do
    get subclauses_url, as: :json
    assert_response :success
  end

  test "should create subclause" do
    assert_difference('Subclause.count') do
      post subclauses_url, params: { subclause: { clause_id: @subclause.clause_id, identifier: @subclause.identifier, number: @subclause.number, text: @subclause.text } }, as: :json
    end

    assert_response 201
  end

  test "should show subclause" do
    get subclause_url(@subclause), as: :json
    assert_response :success
  end

  test "should update subclause" do
    patch subclause_url(@subclause), params: { subclause: { clause_id: @subclause.clause_id, identifier: @subclause.identifier, number: @subclause.number, text: @subclause.text } }, as: :json
    assert_response 200
  end

  test "should destroy subclause" do
    assert_difference('Subclause.count', -1) do
      delete subclause_url(@subclause), as: :json
    end

    assert_response 204
  end
end
