# -*- coding: utf-8 -*-
class DesktopBookmarkController < ApplicationController
  require "nkf"
  require "will_paginate"
  
  require_dependency "lib/windows"
  
  def index
    @work = Work.new
    @works = Work.paginate(:page => params[:page], :per_page => 8, :order => "id DESC")
    @selected_work = Work.current || Work.find_by_id(session[:work_id])
    @selected_tasks = @selected_work.tasks rescue []
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @works }
    end
  end
  
  def discover
  end

  def discover_keyword
  end

  def start
    Work.current = Work.find params[:work_id]
    Task.current = Task.find params[:task_id]

    @selected_work = Work.current
    @selected_tasks = @selected_work.tasks
    bookmark = Bookmark.create(:task_id => params[:task_id],
                               :thumbnail => Time.now.strftime("%Y%m%d%H%M%S"))
    Bookmark.current = bookmark
    respond_to do |format|
      format.js
    end
  end
  
  def stop
    # たぶんこれで動く．うごいてるはず
    Bookmark.current.update_attributes(:comment => params[:bookmark][:comment])
    reset_accesslog
    
    Work.current = nil
    Task.current = nil
    Bookmark.current = nil

    @selected_work = nil
    @selected_tasks = []
    respond_to do |format|
      format.js
    end
  end
  
  private

  def reset_accesslog
    dst = WindowsLibs.make_path(["", "squid", "var", "logs", "access.log"])
    `type nul > #{dst}`
  end
end
