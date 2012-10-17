# -*- coding: utf-8-with-signature -*-
class Work < ActiveRecord::Base
  has_many :tasks, :dependent => :destroy

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
  
  def self.options_for_seelct
    res = [["-----仕事を選択してください-----", ""]]
    Work.all.each do |work|
      res << [work.name, work.id]
    end
    return res
  end
  
  def last_update
    res = updated_at
    tasks.each do |task|
      res = (res <= task.updated_at ? task.last_update : res)
    end
  end

  def self.current
    @current_work
  end

  def self.current=(work)
    @current_work = work
  end


end
