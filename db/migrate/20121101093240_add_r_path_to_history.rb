class AddRPathToHistory < ActiveRecord::Migration
  def change
    add_column :histories, :r_path, :string
  end
end
