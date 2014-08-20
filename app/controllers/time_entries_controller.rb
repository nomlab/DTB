class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy]

  def index
    @time_entries = TimeEntry.all
  end

  def show
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
        format.html { redirect_to @time_entry, notice: 'Time entry was successfully created.' }
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
        format.html { redirect_to @time_entry, notice: 'Time entry was successfully updated.' }
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
    redirect_to :back, notice: 'Undefined'
  end

  def import
    TimeEntry.import
    redirect_to :back, notice: 'Import time entry'
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
