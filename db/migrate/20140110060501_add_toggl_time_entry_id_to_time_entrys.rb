class AddTogglTimeEntryIdToTimeEntrys < ActiveRecord::Migration
  def change
    add_column :time_entries, :toggl_time_entry_id, :integer
  end
end
