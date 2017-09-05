class SubparagraphsController < ApplicationController
  before_action :set_subparagraph, only: [:show, :update, :destroy]

  # GET /subparagraphs
  def index
    @subparagraphs = Subparagraph.all

    render json: @subparagraphs
  end

  # GET /subparagraphs/1
  def show
    render json: @subparagraph
  end

  # POST /subparagraphs
  def create
    @subparagraph = Subparagraph.new(subparagraph_params)

    if @subparagraph.save
      render json: @subparagraph, status: :created, location: @subparagraph
    else
      render json: @subparagraph.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subparagraphs/1
  def update
    if @subparagraph.update(subparagraph_params)
      render json: @subparagraph
    else
      render json: @subparagraph.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subparagraphs/1
  def destroy
    @subparagraph.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subparagraph
      @subparagraph = Subparagraph.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subparagraph_params
      params.require(:subparagraph).permit(:number, :identifier, :chapeau, :text, :paragraph_id, :clause_id)
    end
end
