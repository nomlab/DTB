class BookmarksFileHistories < ActiveRecord::Base
  belongs_to :bookmark
  belongs_to :file_history
end
