# -*- coding: utf-8 -*-
class Task < ActiveRecord::Base
  has_many :bookmarks, :dependent => :destroy
  belongs_to :work, :touch => true

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

  def self.options_for_select
    res = [["-----作業を選択してください-----", ""]]
    Task.all.each do |task|
      res << [task.name, task.id]
    end
    return res
  end

  def self.current
    @current_task
  end
  
  def self.current=(task)
    @current_task = task
  end
end
