class FileHistory < ActiveRecord::Base
  has_many :bookmarks_file_historiess, :dependent => :destroy
  has_many :bookmarks, :through => :bookmarks_file_historiess

end
