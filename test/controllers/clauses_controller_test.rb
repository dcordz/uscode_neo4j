require 'test_helper'

class ClausesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @clause = clauses(:one)
  end

  test "should get index" do
    get clauses_url, as: :json
    assert_response :success
  end

  test "should create clause" do
    assert_difference('Clause.count') do
      post clauses_url, params: { clause: { identifier: @clause.identifier, number: @clause.number, subparagraph_id: @clause.subparagraph_id, text: @clause.text } }, as: :json
    end

    assert_response 201
  end

  test "should show clause" do
    get clause_url(@clause), as: :json
    assert_response :success
  end

  test "should update clause" do
    patch clause_url(@clause), params: { clause: { identifier: @clause.identifier, number: @clause.number, subparagraph_id: @clause.subparagraph_id, text: @clause.text } }, as: :json
    assert_response 200
  end

  test "should destroy clause" do
    assert_difference('Clause.count', -1) do
      delete clause_url(@clause), as: :json
    end

    assert_response 204
  end
end
