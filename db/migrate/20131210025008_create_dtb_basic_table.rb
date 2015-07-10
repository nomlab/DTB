class CreateDtbBasicTable < ActiveRecord::Migration
  def change
    create_table :missions do |t|
      t.string :name
      t.string :description
      t.datetime :deadline
      t.integer :state_id
      t.string :keyword
      t.integer :parent_id

      t.timestamps
    end

    create_table :tasks do |t|
      t.string :name
      t.string :description
      t.datetime :deadline
      t.integer :state_id
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
      t.string :type
      t.string :r_path
      t.datetime :start_time
      t.datetime :end_time
      t.string :thumbnail

      t.index :type # for Single Table Inheritance

      t.timestamps
    end

    create_table :states do |t|
      t.string :name
      t.string :color
      t.integer :position
      t.boolean :default, :default => false

      t.timestamps
    end
  end
end
