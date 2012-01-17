class WebHistory < ActiveRecord::Base
  has_many :bookmarks_web_historiess, :dependent => :destroy
  has_many :bookmarks, :through => :bookmarks_web_historiess

end
