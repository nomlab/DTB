class CreateModels < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :name
      t.text :description, :default => ""
      t.text :keyword
      t.datetime :deadline
      t.boolean :status

      t.timestamps
    end
    
    create_table :bookmarks do |t|
      t.string :name
      t.string :keyword
      t.text :comment, :default => ""
      t.datetime :start_time
      t.datetime :end_time
      t.string :thumbnail
      t.integer :task_id

      t.timestamps
    end

    create_table :histories do |t|
      t.string :path
      t.string :title
      t.string :type

      t.timestamps
    end

    create_table :timelines do |t|
      t.integer :bookmark_id
      t.integer :history_id
      t.string :thumbnail
      
      t.timestamps
    end

    create_table :exticons do |t|
      t.string   :ext
      t.datetime :created_on
      t.datetime :updated_on
    end
  end
end

