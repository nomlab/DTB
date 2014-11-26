class CreateDtbBasicTable < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.string :name
      t.string :description
      t.datetime :deadline
      t.boolean :status, :default => false
      t.string :keyword
      t.integer :parent_id

      t.timestamps
    end

    create_table :tasks do |t|
      t.string :name
      t.string :description
      t.datetime :deadline
      t.boolean :status, :default => false
      t.string :keyword
      t.integer :mission_id

      t.timestamps
    end

    create_table :time_entries do |t|
      t.string :name
      t.string :keyword
      t.text :comment
      t.datetime :start_time
      t.datetime :end_time
      t.integer :toggl_time_entry_id
      t.integer :task_id

      t.timestamps
    end

    create_table :unified_histories do |t|
      t.string :title
      t.string :path
      t.string :history_type
      t.string :usage
      t.string :r_path
      t.datetime :start_time
      t.datetime :end_time
      t.string :thumbnail

      t.timestamps
    end
  end
end
