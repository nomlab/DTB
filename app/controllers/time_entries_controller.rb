class TimeEntriesController < ApplicationController
  before_action :set_time_entry, only: [:show, :edit, :update, :destroy]

  # GET /time_entries
  # GET /time_entries.json
  def index
    @time_entries = TimeEntry.all
  end

  # GET /time_entries/1
  # GET /time_entries/1.json
  def show
  end

  # GET /time_entries/new
  def new
    @time_entry = TimeEntry.new
  end

  # GET /time_entries/1/edit
  def edit
  end

  # POST /time_entries
  # POST /time_entries.json
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

  # PATCH/PUT /time_entries/1
  # PATCH/PUT /time_entries/1.json
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

  # DELETE /time_entries/1
  # DELETE /time_entries/1.json
  def destroy
    @time_entry.destroy
    respond_to do |format|
      format.html { redirect_to time_entries_url }
      format.json { head :no_content }
    end
  end

  def start
    options = Hash.new
    options["description"] = params[:description]
    response = TimeEntry.start(options)
    @time_entry = TimeEntry.new({name: response["description"], start_time: Time.parse(response["start"]),
                                  toggl_time_entry_id: response["id"], running_status: true})
    if @time_entry.save
      redirect_to :back, notice: 'Time entry is running.'
    else
      redirect_to :back, notice: 'Time entry couldn`t run.'
    end
  end

  def stop
    @time_entry = TimeEntry.find(params[:id])
    response = @time_entry.stop
    `sudo pkill -f dtrace`
    `rails runner lib/file_log_daemon.rb stop`
    histories = File.readlines("#{Rails.root}/log/filehistory.log")
    file_histories = Array.new

    histories.each do |history|
      if history.blank? == false
        array = history.split(" ")
        path = array.first
        title = path.split.last
        start_time = Time.parse("1970-01-01 00:00:00 +0000") + array.last.to_i * (0.000000001)
        end_time = Time.parse(`ls -lu #{path} | awk '{print $6, $7, $8}'`)
        file_histories << UnifiedHistory.new({path: path, title: title, history_type: "file_history",
                                               start_time: start_time, end_time: end_time})
      end
    end

    file_histories.uniq! {|history| history.path}
    file_histories.each do |history|
      history.save
    end

    if @time_entry.update({end_time: (Time.parse(response["start"]) + response["duration"]),
                            running_status: false})
      redirect_to :back, notice: 'Time entry stoped.'
    else
      redirect_to :back, notice: 'Time entry couldn`t stop.'
    end
    `#{Rails.root.to_s}/lib/file_log_daemon.rb start`
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
