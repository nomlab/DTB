class TasksController < ApplicationController
  before_action :set_task, only: [:show, :edit, :update, :destroy, :continue]

  # GET /tasks
  # GET /tasks.json
  def index
    @tasks = Task.all
    @tasks = Task.where(mission_id: params[:mission_id]) if params[:mission_id]
    @tasks = Task.where(mission_id: nil) if params[:unorganized]
    respond_to do |format|
      format.html
      format.json
      format.occurrence { render json: @tasks.map(&:to_occurrences) }
    end
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
    respond_to do |format|
      format.html
      format.json
      format.occurrence { render json: @task.time_entries.map(&:to_occurrence) }
    end
  end

  # GET /tasks/new
  def new
    @task = Task.new
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
        format.html do
          flash[:success] = 'Task was successfully created.'
          redirect_to @task
        end
        format.json { render action: 'show', status: :created, location: @task }
      else
        format.html { render action: 'new' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html do
          flash[:success] = 'Task was successfully updated.'
          redirect_to @task
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url }
      format.json { head :no_content }
    end
  end

  def continue
    if TimeEntry.start({ description: @task.name }, @task.id)
      flash[:success] = 'Time entry was successfully started.'
    else
      flash[:warning] = 'Failed to start time entry.'
    end
    redirect_to :back
  end

  def simple_create
    state = State.find_by(default: true)
    if state.nil?
      flash[:warning] = 'Set default state in Setting.'
    else
      @task = Task.new(name: params[:name],
                       mission_id: params[:mission_id],
                       state_id: state.id)
      @task.save ? flash[:success] = 'Task was successfully created.' :
                   flash[:warning] = 'Failed to create task.'
    end
    redirect_to :back
  end

  def organize
    @tasks = Task.where(mission_id: nil)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def task_params
    params.require(:task).permit(:name, :description, :deadline, :state_id, :keyword, :mission_id)
  end
end
