# -*- coding: utf-8 -*-
class Work < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy
  has_many :children, :class_name => "Work", :foreign_key => :parent_id
  belongs_to :parent, :class_name => "Work", :foreign_key => :parent_id

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
    tasks.each do |task|
      res += task.web_histories
    end
    return res.uniq
  end

  def deadline
    return @deadline if @deadline
    list = self.children.where("status IS 'f' OR status IS NULL") + self.tasks.where("status IS 'f' OR status IS NULL")
    return list.sort{|a, b| a.deadline <=> b.deadline }.first.deadline if list != []
  end

  def parent
    parent_id ? Work.find_by_id(parent_id) : nil
  end

  def children
    Work.where(:parent_id => id)
  end

  def root
    root? ? self : parent.root
  end

  def root?
    !parent
  end
  
  def bread_cramb
    res = [self]
    unless root?
      res = parent.bread_cramb + res
    end
    return res
  end
  
  def level
    return ""       if deadline == nil
    return "red" if (deadline - Time.now) <= (3600*24*3) 
    return "yellow" if (deadline - Time.now) <= (3600*24*7)
  end

  def self.current
    $current_work
  end

  def self.current=(work)
    $current_work = work
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
      dir_name = bread_cramb.map{|w| w.name}.join("/")
      print "#{dir_name}\n"
      Dir::mkdir dir_name
      dummyfile = "#{dir_name}/dummy"
      FileUtils.touch dummyfile
      repo = Grit::Repo.new "."
      new_blob = Grit::Blob.create(repo, {:name => dummyfile,
                                     :data => File.read(dummyfile)})
      repo.add(new_blob.name.encode(Encoding::Windows_31J))
      repo.commit_index "you registered a new work \"#{self.name}\" at #{Time.now.strftime("%Y/%m/%d %H:%M")}.\n"
    }
    # for thumbnail
    Dir::chdir("app/assets/images/thumbnail"){
      dir_name = bread_cramb.map{|w|w.name}.join("/")
      Dir::mkdir dir_name
    }
  end

  def delete_directory
    Dir::chdir("repository"){
#      self.tasks.each do |task|
#        task.destroy
#      end
      FileUtils.rm_rf(self.bread_cramb.map{|w| w.name }.join("/"))
    }
    # for thumbnail
    Dir::chdir("app/assets/images/thumbnail"){
      FileUtils.rm_rf(self.bread_cramb.map{|w| w.name }.join("/"))
    }
  end
end
