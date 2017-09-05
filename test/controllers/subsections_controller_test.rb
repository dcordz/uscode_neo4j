require 'test_helper'

class SubsectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @subsection = subsections(:one)
  end

  test "should get index" do
    get subsections_url, as: :json
    assert_response :success
  end

  test "should create subsection" do
    assert_difference('Subsection.count') do
      post subsections_url, params: { subsection: { chapeau: @subsection.chapeau, heading: @subsection.heading, identifier: @subsection.identifier, number: @subsection.number, paragraph_id: @subsection.paragraph_id, section_id: @subsection.section_id, text: @subsection.text } }, as: :json
    end

    assert_response 201
  end

  test "should show subsection" do
    get subsection_url(@subsection), as: :json
    assert_response :success
  end

  test "should update subsection" do
    patch subsection_url(@subsection), params: { subsection: { chapeau: @subsection.chapeau, heading: @subsection.heading, identifier: @subsection.identifier, number: @subsection.number, paragraph_id: @subsection.paragraph_id, section_id: @subsection.section_id, text: @subsection.text } }, as: :json
    assert_response 200
  end

  test "should destroy subsection" do
    assert_difference('Subsection.count', -1) do
      delete subsection_url(@subsection), as: :json
    end

    assert_response 204
  end
end
