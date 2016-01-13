class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy, :update_task_id]

  def index
    unless params[:task_id].nil?
      task_id = params[:task_id] == 'nil' ? nil : params[:task_id]
      @time_entries = TimeEntry.where(task_id: task_id)
    else
      @time_entries = TimeEntry.all
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: [@time_entry.to_event] }
    end
  end

  def new
    @time_entry = TimeEntry.new
  end

  def edit
  end

  def create
    @time_entry = TimeEntry.new(time_entry_params)

    respond_to do |format|
      if @time_entry.save
        format.html do
          flash[:success] = 'Time entry was successfully created.'
          redirect_to @time_entry
        end
        format.json { render action: 'show', status: :created, location: @time_entry }
      else
        format.html { render action: 'new' }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @time_entry.update(time_entry_params)
        format.html do
          flash[:success] = 'Time entry was successfully updated.'
          redirect_to @time_entry
        end
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @time_entry.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @time_entry.destroy
    respond_to do |format|
      format.html { redirect_to time_entries_url }
      format.json { head :no_content }
    end
  end

  def continue
    if TimeEntry.start({ description: params[:name] }, params[:task_id])
      flash[:success] = 'Time entry was successfully started.'
    else
      flash[:warning] = 'Failed to start time entry'
    end
    redirect_to :back
  end

  def stop
    TimeEntry.stop ? flash[:success] = 'Time entry was successfully stopped.' :
                     flash[:warnig] = 'Failed to stop time entry.'
    redirect_to :back
  end

  def organize
    @time_entries = TimeEntry.where(task_id: nil)
    @tasks = Task.all
  end

  def sync
    if params[:start] || params[:end]
      TimeEntry.partial_sync(params[:start], params[:end])
    else
      TimeEntry.completely_sync
    end
    flash[:success] = 'TimeEntries were successfully synced.'
    redirect_to :back
  end

  #---------- for ajax ----------
  def update_task_id
    task_id = params[:task_id] == 'nil' ? nil : params[:task_id] unless params[:task_id].nil?
    @time_entry.update_attribute(:task_id, task_id)
    respond_to do |format|
      format.html do
        flash[:success] = 'TimeEntry was successfully updated.'
        redirect_to @time_entry
      end
      format.json { render json: @time_entry }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_time_entry
    @time_entry = TimeEntry.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def time_entry_params
    params.require(:time_entry).permit(:name, :keyword, :comment, :start_time, :end_time, :thumbnail, :task_id, :toggl_time_entry_id, :running_status)
  end
end
