# -*- coding: utf-8 -*-
class WebHistoriesController < ApplicationController
  require_dependency "lib/windows"

  def show
    @bookmark = Bookmark.find(params[:bookmark_id])

    respond_to do |format|
      format.html # index.html
      format.xml  { render :xml => @bookmark.web_histories.uniq }
    end
  end

  def new
    @bookmark = Bookmark.find(params[:bookmark_id])
    @web_history = WebHistory.new(:bookmark_id => @bookmark)
  end

  def create
    @bookmark = Bookmark.find(params[:bookmark_id])
    @web_history = WebHistory.create(params[:web_history][:path])
    Timeline.create(:bookmark_id => @bookmark, :history_id => @web_history)
    flash[:notice] = "計算機外部の履歴情報を追加しました．"
  end

  def edit
    @bookmark = Bookmark.find(params[:bookmark_id])
    @histories = @bookmark.web_histories
  end

  def update
    @bookmark = Bookmark.find(params[:bookmark_id])
    @bookmark.timelines.where(:history_id => params[:histories]).destroy_all

    respond_to do |format|
      flash[:notice] = "計算機外部の履歴情報を更新しました．"
      format.html {redirect_to :controller => "bookmark", :action => "show", :id => params[:bookmark_id]}
      format.xml  {head :ok}
    end
  end

  def destroy
    @bookmark = Bookmark.find(params[:bookmark_id])
    @bookmark.timelines.where(:history_id => params[:histories]).destroy_all

    respond_to do |format|
      flash[:notice] = "計算機外部の履歴情報を更新しました．"
      format.html { redirect_to :controller => "bookmarks", :action => "show", :id => params[:bookmark_id] }
      format.xml  { head :ok }
    end
  end
end
