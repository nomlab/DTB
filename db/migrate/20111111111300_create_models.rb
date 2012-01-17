class CreateModels < ActiveRecord::Migration
  def change
    create_table :bookmarks do |t|
      t.string :name
      t.string :keyword
      t.text :comment
      t.boolean :visible
      t.datetime :start_time
      t.datetime :end_time

      t.timestamps
    end

    create_table :file_histories do |t|
      t.string :path
      t.string :title
      t.string :thumbnail

      t.timestamps
    end

    create_table :web_histories do |t|
      t.string :path
      t.string :title
      t.string :thumbnail

      t.timestamps
    end

    create_table :bookmarks_file_histories do |t|
      t.integer :bookmark_id
      t.integer :file_history_id

      t.timestamps
    end

    create_table :bookmarks_web_histories do |t|
      t.integer :bookmark_id
      t.integer :web_history_id
      t.string :thumbnail_dir

      t.timestamps
    end

    create_table :exticons do |t|
      t.string   :ext
      t.datetime :created_on
      t.datetime :updated_on
    end
  end
end

