class SubsectionsController < ApplicationController
  before_action :set_subsection, only: [:show, :update, :destroy]

  # GET /subsections
  def index
    @subsections = Subsection.all

    render json: @subsections
  end

  # GET /subsections/1
  def show
    render json: @subsection
  end

  # POST /subsections
  def create
    @subsection = Subsection.new(subsection_params)

    if @subsection.save
      render json: @subsection, status: :created, location: @subsection
    else
      render json: @subsection.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /subsections/1
  def update
    if @subsection.update(subsection_params)
      render json: @subsection
    else
      render json: @subsection.errors, status: :unprocessable_entity
    end
  end

  # DELETE /subsections/1
  def destroy
    @subsection.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_subsection
      @subsection = Subsection.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def subsection_params
      params.require(:subsection).permit(:heading, :identifier, :chapeau, :text, :number, :section_id, :paragraph_id)
    end
end
