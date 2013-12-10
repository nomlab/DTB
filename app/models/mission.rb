class Mission < ActiveRecord::Base
  has_many :children, :class_name => "Mission", :foreign_key => :parent_id
  belongs_to :parent, :class_name => "Mission", :foreign_key => :parent_id
end
