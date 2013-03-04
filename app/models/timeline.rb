class Timeline < ActiveRecord::Base
  belongs_to :bookmark
  belongs_to :history
end
