class UnifiedHistoriesController < ApplicationController
  before_action :set_unified_history, only: [:show, :edit, :update, :destroy]

  # GET /unified_histories
  # GET /unified_histories.json
  def index
    @unified_histories = UnifiedHistory.all
  end

  # GET /unified_histories/1
  # GET /unified_histories/1.json
  def show
  end

  # GET /unified_histories/new
  def new
    @unified_history = UnifiedHistory.new
  end

  # GET /unified_histories/1/edit
  def edit
  end

  # POST /unified_histories
  # POST /unified_histories.json
  def create
    @unified_history = UnifiedHistory.new(unified_history_params)

    respond_to do |format|
      if @unified_history.save
        format.html { redirect_to @unified_history, notice: 'Unified history was successfully created.' }
        format.json { render action: 'show', status: :created, location: @unified_history }
      else
        format.html { render action: 'new' }
        format.json { render json: @unified_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /unified_histories/1
  # PATCH/PUT /unified_histories/1.json
  def update
    respond_to do |format|
      if @unified_history.update(unified_history_params)
        format.html { redirect_to @unified_history, notice: 'Unified history was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @unified_history.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /unified_histories/1
  # DELETE /unified_histories/1.json
  def destroy
    @unified_history.destroy
    respond_to do |format|
      format.html { redirect_to unified_histories_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_unified_history
      @unified_history = UnifiedHistory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def unified_history_params
      params.require(:unified_history).permit(:path, :title, :type, :r_path, :start_time, :end_time)
    end
end
