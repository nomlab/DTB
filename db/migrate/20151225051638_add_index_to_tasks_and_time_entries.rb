class AddIndexToTasksAndTimeEntries < ActiveRecord::Migration
  def self.up
    add_index :tasks,        :mission_id
    add_index :time_entries, :task_id
  end

  def self.down
    remove_index :tasks,        :mission_id
    remove_index :time_entries, :task_id
  end
end
