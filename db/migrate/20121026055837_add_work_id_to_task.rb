class AddWorkIdToTask < ActiveRecord::Migration
  def change
    add_column :tasks, :work_id, :integer
  end
end
