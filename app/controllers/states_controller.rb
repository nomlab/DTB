class StatesController < ApplicationController
  before_action :set_state, only: [:show, :edit, :update, :destroy, :update_color, :update_default]

  # GET /states
  # GET /states.json
  def index
    @states = State.all
  end

  # GET /states/1
  # GET /states/1.json
  def show
  end

  # GET /states/new
  def new
    @state = State.new
  end

  # GET /states/1/edit
  def edit
  end

  # POST /states
  # POST /states.json
  def create
    @state = State.new(state_params)

    respond_to do |format|
      if @state.save
        format.html {
          flash[:success] = 'State was successfully created.'
          redirect_to action: 'index'
        }
        format.json { render action: 'show', status: :created, location: @state }
      else
        format.html { render action: 'new' }
        format.json { render json: @state.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /states/1
  # PATCH/PUT /states/1.json
  def update
    respond_to do |format|
      if @state.update(state_params)
        format.html {
          flash[:success] = 'State was successfully updated.'
          redirect_to action: 'index'
        }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @state.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /states/1
  # DELETE /states/1.json
  def destroy
    @state.destroy
    respond_to do |format|
      format.html { redirect_to states_url }
      format.json { head :no_content }
    end
  end

  def update_color
    @state.update_attribute(:color, params[:color])
    flash[:success] = "State was successfully updated."
    redirect_to :back
  end

  def update_default
    default_state = State.find_by(default: true)
    default_state.update_attribute(:default, false) unless default_state.nil?
    @state.update_attribute(:default, true)
    flash[:success] = "Default state was successfully updated."
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_state
      @state = State.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def state_params
      params.require(:state).permit(:name, :color, :position)
    end
end
