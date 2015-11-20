class AddImportanceToUnifiedHistory < ActiveRecord::Migration
  def self.up
    add_column :unified_histories, :importance, :integer

    UnifiedHistory.all.each do |history|
      history.update_attribute(:importance, history.duration.length)
    end
  end

  def self.down
    remove_column :unified_histories, :importance, :integer
  end
end
