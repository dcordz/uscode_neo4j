require 'test_helper'

class SectionParagraphsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @section_paragraph = section_paragraphs(:one)
  end

  test "should get index" do
    get section_paragraphs_url, as: :json
    assert_response :success
  end

  test "should create section_paragraph" do
    assert_difference('SectionParagraph.count') do
      post section_paragraphs_url, params: { section_paragraph: { chapeau: @section_paragraph.chapeau, identifier: @section_paragraph.identifier, number: @section_paragraph.number, section_id: @section_paragraph.section_id, subparagraph_id: @section_paragraph.subparagraph_id, text: @section_paragraph.text } }, as: :json
    end

    assert_response 201
  end

  test "should show section_paragraph" do
    get section_paragraph_url(@section_paragraph), as: :json
    assert_response :success
  end

  test "should update section_paragraph" do
    patch section_paragraph_url(@section_paragraph), params: { section_paragraph: { chapeau: @section_paragraph.chapeau, identifier: @section_paragraph.identifier, number: @section_paragraph.number, section_id: @section_paragraph.section_id, subparagraph_id: @section_paragraph.subparagraph_id, text: @section_paragraph.text } }, as: :json
    assert_response 200
  end

  test "should destroy section_paragraph" do
    assert_difference('SectionParagraph.count', -1) do
      delete section_paragraph_url(@section_paragraph), as: :json
    end

    assert_response 204
  end
end
