class AddRunningStatusToTimeEntries < ActiveRecord::Migration
  def change
    add_column :time_entries, :running_status, :boolean, :default => false
  end
end
