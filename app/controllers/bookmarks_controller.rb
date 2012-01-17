# -*- coding: utf-8 -*-
class BookmarksController < ApplicationController
  def index
  end
  
  def new
    @bookmark = Bookmark.new
  end
  
  def create
    @bookmark = Bookmark.new(params[:bookmark])

    respond_to do |format|
      if @bookmark.save
        flash[:notice] = "仕事状態を保存しました．"
        format.html { redirect_to( :controller => "desktop_bookmark", :action => "init" ) }
        format.xml { render :xml => @bookmark, :status => :created, :location => @bookmark }
      else
        flash[:notice] = "仕事状態の保存に失敗しました．"
        format.html { render :action => "new" }
        format.xml { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @bookmark = Bookmark.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @bookmark }
    end
  end
  
  def edit
    @bookmark = Bookmark.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml { render :xml => @bookmark }
    end
  end

  def update
    @bookmark = Bookmark.find(params[:id])

    respond_to do |format|
      if @bookmark.update_attributes(params[:bookmark])
        flash[:notice] = "Update succeeded."
        format.html { redirect_to(:action => "show", :id => @bookmark) }
        format.xml  { head :ok }
      else
        flash[:notice] = "Update failed."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @bookmark.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @bookmark = Bookmark.find(params[:id])
    @bookmark.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => "desktop_bookmark", :action => "index") }
      format.xml  { head :ok }
    end
  end

  def phoenix
    @bookmark = Bookmark.find(params[:id])
    
    files = @bookmark.file_histories.uniq
    files.each do |file|
      # FileHistoryに参照用のメソッド用意すべき？
      WindowsLibs.restore_ap(file.path, false)
    end
    redirect_to :action => "show", :id => @bookmark
  end
end
