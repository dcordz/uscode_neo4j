class SectionParagraphsController < ApplicationController
  before_action :set_section_paragraph, only: [:show, :update, :destroy]

  # GET /section_paragraphs
  def index
    @section_paragraphs = SectionParagraph.all

    render json: @section_paragraphs
  end

  # GET /section_paragraphs/1
  def show
    render json: @section_paragraph
  end

  # POST /section_paragraphs
  def create
    @section_paragraph = SectionParagraph.new(section_paragraph_params)

    if @section_paragraph.save
      render json: @section_paragraph, status: :created, location: @section_paragraph
    else
      render json: @section_paragraph.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /section_paragraphs/1
  def update
    if @section_paragraph.update(section_paragraph_params)
      render json: @section_paragraph
    else
      render json: @section_paragraph.errors, status: :unprocessable_entity
    end
  end

  # DELETE /section_paragraphs/1
  def destroy
    @section_paragraph.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_section_paragraph
      @section_paragraph = SectionParagraph.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def section_paragraph_params
      params.require(:section_paragraph).permit(:number, :identifier, :text, :chapeau, :section_id, :subparagraph_id)
    end
end
