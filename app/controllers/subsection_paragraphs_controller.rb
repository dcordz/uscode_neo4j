class SubsectionParagraphsController < ApplicationController
  before_action :set_subsection_paragraph, only: [:show, :update, :destroy]

  # GET /subsection_paragraphs
  def index
    @subsection_paragraphs = SubsectionParagraph.all

    render json: @subsection_paragraphs
  end

  # GET /subsection_paragraphs/1
  def show
    render json: @subsection_paragraph
  end

  # POST /subsection_paragraphs
  def create
    @subsection_paragraph = SubsectionParagraph.new(subsection_paragraph_params)

    if @subsection_paragraph.save
      render json: @subsection_paragraph, status: :created, location: @subsection_paragraph
    else
      render json: @subsection_paragraph.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subsection_paragraphs/1
  def update
    if @subsection_paragraph.update(subsection_paragraph_params)
      render json: @subsection_paragraph
    else
      render json: @subsection_paragraph.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subsection_paragraphs/1
  def destroy
    @subsection_paragraph.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subsection_paragraph
      @subsection_paragraph = SubsectionParagraph.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subsection_paragraph_params
      params.require(:subsection_paragraph).permit(:number, :identifier, :text, :chapeau, :subsection_id, :subparagraph_id)
    end
end
