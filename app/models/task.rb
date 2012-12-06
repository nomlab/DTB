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

  def self.current
    $current_task
  end
  
  def self.current=(task)
    $current_task = task
  end

  def create_directory
    Dir::chdir("repository"){
      Dir::mkdir "#{self.work.name}/#{self.name}"
      dummyfile = "#{self.work.name}/#{self.name}/dummy"
      FileUtils.touch dummyfile
      repo = Grit::Repo.new "."
      new_blob = Grit::Blob.create(repo, {:name => dummyfile, :data => File.read(dummyfile)})
      repo.add(new_blob.name.encode(Encoding::Windows_31J))
      repo.commit_index "you registered new task #{self.name} to #{self.work.name} at #{Time.now.strftime("%Y/%m/%d %H:%M")}\n"
    }
  end

  def delete_directory
    Dir::chdir("repository"){
      delete_dir = "#{self.work.name}/#{self.name}"
      Dir::foreach(delete_dir) {|f|
        File::delete(delete_dir + "/" + f) if !(/\.+$/ =~ f)
      }
      Dir::rmdir(delete_dir)
    }
  end
end
