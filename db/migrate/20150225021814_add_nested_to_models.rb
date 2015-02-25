class AddNestedToModels < ActiveRecord::Migration
  def self.up
    add_column :missions, :lft, :integer
    add_column :missions, :rgt, :integer
    add_column :missions, :depth, :integer

    add_index :missions, :parent_id
    add_index :missions, :lft
    add_index :missions, :rgt
    add_index :missions, :depth

    Mission.where(parent_id: 0).update_all(parent_id: nil)
    Mission.rebuild!
  end

  def self.down
    remove_index :missions, :parent_id
    remove_index :missions, :lft
    remove_index :missions, :rgt
    remove_index :missions, :depth

    remove_column :missions, :lft, :integer
    remove_column :missions, :rgt, :integer
    remove_column :missions, :depth, :integer
    remove_column :missions, :children_count, :integer
  end
end
