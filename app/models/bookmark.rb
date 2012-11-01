# -*- coding: utf-8 -*-
class Bookmark < ActiveRecord::Base
  has_many :histories, :through => :timelines
  has_many :timelines, :dependent => :destroy
  belongs_to :task, :touch => true
  
  def file_histories
    histories.where(:type => "FileHistory")
  end
  
  def web_histories
    histories.where(:type => "WebHistory")
  end
  
  def thumbnail_tag
    tag = ""
    web_histories.each do |wh|
      tag << <<"EOS"
<a href=#{wh.path}>
#{image_tag("thumbnail/#{thumbnail}/thumbnail_#{wh.timelines.where(:bookmark_id => id).last.thumbnail}.jpg",
:alt => wh.path, :height => 200, :width => 250, :title => wh.path, :class => "thumbnail")}
</a>
EOS
    end
    tag.html_safe
  end
end
