require 'test_helper'

class SubparagraphsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subparagraph = subparagraphs(:one)
  end

  test "should get index" do
    get subparagraphs_url, as: :json
    assert_response :success
  end

  test "should create subparagraph" do
    assert_difference('Subparagraph.count') do
      post subparagraphs_url, params: { subparagraph: { chapeau: @subparagraph.chapeau, clause_id: @subparagraph.clause_id, identifier: @subparagraph.identifier, number: @subparagraph.number, paragraph_id: @subparagraph.paragraph_id, text: @subparagraph.text } }, as: :json
    end

    assert_response 201
  end

  test "should show subparagraph" do
    get subparagraph_url(@subparagraph), as: :json
    assert_response :success
  end

  test "should update subparagraph" do
    patch subparagraph_url(@subparagraph), params: { subparagraph: { chapeau: @subparagraph.chapeau, clause_id: @subparagraph.clause_id, identifier: @subparagraph.identifier, number: @subparagraph.number, paragraph_id: @subparagraph.paragraph_id, text: @subparagraph.text } }, as: :json
    assert_response 200
  end

  test "should destroy subparagraph" do
    assert_difference('Subparagraph.count', -1) do
      delete subparagraph_url(@subparagraph), as: :json
    end

    assert_response 204
  end
end
