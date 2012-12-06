# -*- coding: utf-8 -*-
class Work < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  after_create :create_directory
  before_destroy :delete_directory

  def file_histories
    res = []
    tasks.each do |task|
      res += task.file_histories
    end
    return res.uniq
  end

  def web_histories
    res = []
    tasks.eac do |task|
      res += task.web_histories
    end
    return res.uniq
  end

  def level
    return ""       if deadline == nil
    return "red"    if deadline.yday - Time.now.yday <= 3
    return "yellow" if deadline.yday - Time.now.yday <= 7
  end

  def self.current
    $current_work
  end

  def self.current=(work)
    $current_work = work
  end

  def create_directory
    Dir::chdir("repository"){
      Dir::mkdir self.name
      dummyfile = "#{self.name}/dummy"
      FileUtils.touch dummyfile
      repo = Grit::Repo.new "."
      new_blob = Grit::Blob.create(repo, {:name => dummyfile,
                                          :data => File.read(dummyfile)})
      repo.add(new_blob.name.encode(Encoding::Windows_31J))
      repo.commit_index "you registered a new work #{self.name} at #{Time.now.strftime("%Y/%m/%d %H:%M")}.\n"
    }
  end

  def delete_directory
    Dir::chdir("repository"){
#      self.tasks.each do |task|
#        task.destroy
#      end
      File::delete(self.name + "/dummy") rescue nil
      Dir::rmdir(self.name)
    }
  end
end
