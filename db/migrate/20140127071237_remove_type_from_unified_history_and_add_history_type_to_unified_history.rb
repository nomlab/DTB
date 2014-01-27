class RemoveTypeFromUnifiedHistoryAndAddHistoryTypeToUnifiedHistory < ActiveRecord::Migration
  def change
    remove_column :unified_histories, :type, :string
    add_column :unified_histories, :history_type, :string
  end
end
