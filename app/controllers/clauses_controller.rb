class ClausesController < ApplicationController
  before_action :set_clause, only: [:show, :update, :destroy]

  # GET /clauses
  def index
    @clauses = Clause.all

    render json: @clauses
  end

  # GET /clauses/1
  def show
    render json: @clause
  end

  # POST /clauses
  def create
    @clause = Clause.new(clause_params)

    if @clause.save
      render json: @clause, status: :created, location: @clause
    else
      render json: @clause.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /clauses/1
  def update
    if @clause.update(clause_params)
      render json: @clause
    else
      render json: @clause.errors, status: :unprocessable_entity
    end
  end

  # DELETE /clauses/1
  def destroy
    @clause.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_clause
      @clause = Clause.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def clause_params
      params.require(:clause).permit(:number, :identifier, :text, :subparagraph_id)
    end
end
