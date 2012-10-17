# -*- coding: utf-8 -*-
class DesktopBookmarkController < ApplicationController
  require "nkf"
  require "will_paginate"
  
  require_dependency "lib/windows"
  
  def init
    reset_accesslog
    bm = Bookmark.create(:visible => false, :start_time => DateTime.now)
    dirname = bm.created_at.strftime("%Y%m%d%H%M")
    dir = WindowsLibs.make_path(["app", "assets","images", "thumbnail", dirname])
    `mkdir #{dir}`
    
#    BookmarksWebHistories.create(:bookmark => bm, :thumbnail_dir => dirname)
#    BookmarksFileHistories.create(:bookmark => bm)
    
    
    if params[:id]
      redirect_to :controller => "bookmarks", :action => 'show', :id => params[:id]
    else
      redirect_to :action => 'index'
    end
  end
  
  def index
    @tasks = Task.paginate(:page => params[:page], :per_page => 8, :order => "id DESC")
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @bookmarks }
    end
  end
  
  def discover
  end

  def discover_keyword
  end
  
  private

  def reset_accesslog
    dst = WindowsLibs.make_path(["", "squid", "var", "logs", "access.log"])
    `type nul > #{dst}`
  end
end
