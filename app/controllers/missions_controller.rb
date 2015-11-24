class MissionsController < ApplicationController
  before_action :set_mission, only: [:show, :edit, :update, :destroy, :update_parent_id,
                                    :update_state, :update_deadline]

  # GET /missions
  # GET /missions.json
  def index
    unless params[:parent_id].nil?
      parent_id = params[:parent_id] == "nil" ? nil : params[:parent_id]
      @missions = Mission.where(parent_id: parent_id)
    else
      @missions = Mission.all
    end
    respond_to do |format|
      format.html
      format.json
      format.event {render json: @missions.map(&:to_event)}
    end
  end

  # GET /missions/1
  # GET /missions/1.json
  def show
    respond_to do |format|
      format.html
      format.json {render json: @mission.children.map(&:to_event) +
                                @mission.tasks.map(&:to_event)}
    end
  end

  # GET /missions/new
  def new
    @mission = Mission.new
  end

  # GET /missions/1/edit
  def edit
  end

  # POST /missions
  # POST /missions.json
  def create
    @mission = Mission.new(mission_params)

    respond_to do |format|
      if @mission.save
        format.html {
          flash[:success] = "Mission was successfully created."
          redirect_to @mission
        }
        format.json { render action: 'show', status: :created, location: @mission }
      else
        format.html { render action: 'new' }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /missions/1
  # PATCH/PUT /missions/1.json
  def update
    respond_to do |format|
      if @mission.update(mission_params)
        format.html {
          flash[:success] = "Mission was successfully created."
          redirect_to @mission
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @mission.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /missions/1
  # DELETE /missions/1.json
  def destroy
    @mission.destroy
    respond_to do |format|
      format.html { redirect_to missions_url }
      format.json { head :no_content }
    end
  end

  def organize
    @missions = Mission.roots
  end

  def simple_create
    state = State.find_by(default: true)
    if state.nil?
      flash[:warning] = "Set default state in Setting."
    else
      @mission = Mission.new(name: params[:name], parent_id: params[:parent_id], state_id: state.id)
      @mission.save ? flash[:success] = "Mission was successfully created." :
                      flash[:warning] = "Failed to create mission."
    end
    redirect_to :back
  end

  def update_state
    @mission.update_attribute(:state_id, params[:state_id]) unless params[:state_id].nil?
    respond_to do |format|
      format.html {
        flash[:success] = "Mission was successfully updated."
        redirect_to :back
      }
      format.json { render json: @mission }
    end
  end

  def update_deadline
    @mission.update_attribute(:deadline, params[:deadline]) unless params[:deadline].nil?
    respond_to do |format|
      format.html {
        flash[:success] = "Mission was successfully updated."
        redirect_to :back
      }
      format.json { render json: @mission }
    end
  end

  #---------- for ajax ----------
  def update_parent_id
    parent_id = params[:parent_id] == "nil" ? nil : params[:parent_id] unless params[:parent_id].nil?
    @mission.update_attribute(:parent_id, parent_id)
    respond_to do |format|
      format.html {
        flash[:success] = "Mission was successfully updated."
        redirect_to @mission
      }
      format.json { render json: @mission }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mission
      @mission = Mission.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mission_params
      params.require(:mission).permit(:name, :description, :deadline, :state_id, :keyword, :parent_id)
    end
end
