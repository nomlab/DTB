class AddParentIdToWork < ActiveRecord::Migration
  def change
    add_column :works, :parent_id, :integer
  end
end
