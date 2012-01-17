# -*- coding: utf-8 -*-
class FileHistoriesController < ApplicationController
  require_dependency "lib/windows"
  
  def show    
  end

  def new
  end

  def create
  end

  def edit
    @bookmark = Bookmark.find(params[:bookmark_id])
    @histories = @bookmark.file_histories
  end

  def update
    @bookmark = Bookmark.find(params[:bookmark_id])
    @bookmark.bookmarks_file_historiess.where(:file_history_id => params[:histories]).destroy_all

    respond_to do |format|
      flash[:notice] = "計算機内部の履歴情報を更新しました．"
      format.html {redirect_to :controller => "bookmark", :action => "show", :id => params[:bookmark_id]}
      format.xml  {head :ok}
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:bookmark_id])
    @bookmark.bookmarks_file_historiess.where(:file_history_id => params[:histories]).destroy_all

    respond_to do |format|
      flash[:notice] = "計算機内部の履歴情報を更新しました．"
      format.html { redirect_to :controller => "bookmarks", :action => "show", :id => params[:bookmark_id] }
      format.xml  { head :ok }
    end
  end

  def link
    path = FileHistory.find(params[:id]).path
    WindowsLibs.restore_ap(path, params[:format])
    
    redirect_to :controller => "bookmarks", :action => "show", :id => params[:bookmark_id]
  end
end
