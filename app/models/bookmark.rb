class Bookmark < ActiveRecord::Base
  has_many :bookmarks_file_historiess, :dependent => :destroy
  has_many :file_histories, :through => :bookmarks_file_historiess
  has_many :bookmarks_web_historiess, :dependent => :destroy
  has_many :web_histories, :through => :bookmarks_web_historiess
end
