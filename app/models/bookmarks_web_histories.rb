class BookmarksWebHistories < ActiveRecord::Base
  belongs_to :bookmark
  belongs_to :web_history
end
