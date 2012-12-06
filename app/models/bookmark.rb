# -*- coding: utf-8 -*-
class Bookmark < ActiveRecord::Base
  after_update :commit
  after_create :create_directory
  before_destroy :delete_directory

  has_many :histories, :through => :timelines
  has_many :timelines, :dependent => :destroy
  belongs_to :task, :touch => true
  
  def work
    self.task.work
  end

  # please refact to scope
  def file_histories
    histories.where(:type => "FileHistory")
  end
  
  # please refact to scope
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
  
  def self.current
    $current_bookmark
  end

  def self.current=(bookmark)
    $current_bookmark = bookmark
  end

  def create_directory
    Dir::mkdir "app/assets/images/thumbnail/#{self.thumbnail}"
  end
  
  def delete_directory
    Dir::chdir("app/assets/images/thumbnail"){
      delete_dir = "#{self.thumbnail}"
      Dir::foreach(delete_dir){|f|
        File::delete(deelte_dir + "/" + f) if !(/\.+$/ =~ f)
      }
      Dir::rmdir(delete_dir)
    }
  end

  # Git関連のメソッド
  # add all file_histories to index
  def add
    Dir::chdir("repository"){
      repo = Grit::Repo.new "."
      files = (repo.tree / "#{work.name}/#{task.name}".encode(Encoding::Windows_31J)).contents.collect{|c| c.name } rescue []

      file_histories.each do |history|
        if history.r_path == nil
          num = 0
          num+= 1 while files.include?(num.to_s+history.title)
          history.update_attributes :r_path => (num.to_s+history.title)
        end
        dest = "#{work.name}/#{task.name}/#{history.r_path}"
        FileUtils.copy(history.path, dest)
        new_blob = Grit::Blob.create(repo, {:name => dest, :data => File.read(dest)})
        repo.add(new_blob.name.encode(Encoding::Windows_31J))
      end
    }
  end

  # (add &) commit 
  def commit(comment = nil)
    add
    comment ||= 'auto commit at #{Time.now.strftime("%Y/%m/%d %H:%M")}'
    Dir::chdir("repository"){
      repo = Grit::Repo.new "."
      repo.commit_index(comment)
    }
  end
end
