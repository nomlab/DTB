class History < ActiveRecord::Base
  has_many :timelines, :dependent => :destroy
  has_many :bookmarks, :through => :timelines

end

class WebHistory < History
end

class FileHistory < History
end
