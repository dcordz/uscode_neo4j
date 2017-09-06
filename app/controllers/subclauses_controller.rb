class SubclausesController < ApplicationController
  before_action :set_subclause, only: [:show, :update, :destroy]

  # GET /subclauses
  def index
    @subclauses = Subclause.all

    render json: @subclauses
  end

  # GET /subclauses/1
  def show
    render json: @subclause
  end

  # POST /subclauses
  def create
    @subclause = Subclause.new(subclause_params)

    if @subclause.save
      render json: @subclause, status: :created, location: @subclause
    else
      render json: @subclause.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subclauses/1
  def update
    if @subclause.update(subclause_params)
      render json: @subclause
    else
      render json: @subclause.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subclauses/1
  def destroy
    @subclause.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subclause
      @subclause = Subclause.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subclause_params
      params.require(:subclause).permit(:number, :text, :identifier, :clause_id)
    end
end
