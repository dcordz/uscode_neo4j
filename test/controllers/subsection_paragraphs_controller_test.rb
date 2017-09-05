require 'test_helper'

class SubsectionParagraphsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subsection_paragraph = subsection_paragraphs(:one)
  end

  test "should get index" do
    get subsection_paragraphs_url, as: :json
    assert_response :success
  end

  test "should create subsection_paragraph" do
    assert_difference('SubsectionParagraph.count') do
      post subsection_paragraphs_url, params: { subsection_paragraph: { chapeau: @subsection_paragraph.chapeau, identifier: @subsection_paragraph.identifier, number: @subsection_paragraph.number, subparagraph_id: @subsection_paragraph.subparagraph_id, subsection_id: @subsection_paragraph.subsection_id, text: @subsection_paragraph.text } }, as: :json
    end

    assert_response 201
  end

  test "should show subsection_paragraph" do
    get subsection_paragraph_url(@subsection_paragraph), as: :json
    assert_response :success
  end

  test "should update subsection_paragraph" do
    patch subsection_paragraph_url(@subsection_paragraph), params: { subsection_paragraph: { chapeau: @subsection_paragraph.chapeau, identifier: @subsection_paragraph.identifier, number: @subsection_paragraph.number, subparagraph_id: @subsection_paragraph.subparagraph_id, subsection_id: @subsection_paragraph.subsection_id, text: @subsection_paragraph.text } }, as: :json
    assert_response 200
  end

  test "should destroy subsection_paragraph" do
    assert_difference('SubsectionParagraph.count', -1) do
      delete subsection_paragraph_url(@subsection_paragraph), as: :json
    end

    assert_response 204
  end
end
