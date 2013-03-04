# -*- coding: utf-8 -*-
class Task < ActiveRecord::Base
  has_many :bookmarks, :dependent => :destroy
  belongs_to :work, :touch => true
  after_create :create_directory
  before_destroy :delete_directory

  def file_histories
    res = []
    bookmarks.each do |bookmark|
      res += bookmark.file_histories
    end
    return res.uniq
  end

  def web_histories
    res = []
    bookmarks.each do |bookmark|
      res += bookmark.web_histories
    end
    return res.uniq    
  end
  
  def deadline
    return @deadline ? @deadline : self.bookmarks.sort{|a, b| a.end_time <=> b.end_time }.last.end_time
  end

  def level
    return "" if deadline == nil
    return "red" if (deadline - Time.now) <= (3600*24*3) 
    return "yellow" if (deadline - Time.now) <= (3600*24*7)
  end
  
  def bread_cramb
    self.work ? self.work.bread_cramb << self : [self]
  end
  
  def self.current
    $current_task
  end
  
  def self.current=(task)
    $current_task = task
  end
  
  # status == true : finished
  # status == false : unfinished
  def finish 
    self.update_attributes :status => true
  end
  
  def finished?
    return self.status
  end
  
  def create_directory
    Dir::chdir("repository"){
#      dir_name = self.bread_cramb.map{|w|  w.name }.join("/")
      dir_name = self.bread_cramb.map{|w|  w.name }.join("/")
      Dir::mkdir dir_name
      dummyfile = "#{dir_name}/dummy"
      FileUtils.touch dummyfile
      repo = Grit::Repo.new "."
      new_blob = Grit::Blob.create(repo, {:name => dummyfile, :data => File.read(dummyfile)})
      repo.add(new_blob.name.encode(Encoding::Windows_31J))
      repo.commit_index "you registered new task #{self.name} to #{self.work.name} at #{Time.now.strftime("%Y/%m/%d %H:%M")}\n"
    }
    # for thumbnail
    Dir::chdir("app/assets/images/thumbnail"){
      dir_name = self.bread_cramb.map{|w| w.name }.join("/")
      Dir::mkdir dir_name
    }
  end
  
  def delete_directory
    Dir::chdir("repository"){
      delete_dir = self.work.bread_cramb.map{|w| w.name }.join("/") + "/#{self.name}"
      Dir::foreach(delete_dir) {|f|
        File::delete(delete_dir + "/" + f) if !(/\.+$/ =~ f)
      }
      Dir::rmdir(delete_dir)
    }
    # for thumbnail
    Dir::chdir("app/assets/images/thumbnail"){
      FileUtils.rm_rf(self.bread_cramb.map{|w| w.name }.join("/"))
    }
  end
end
