# -*- coding: utf-8 -*-
require "./lib/windows"
class WorksController < ApplicationController
  def index
  end
  
  def new
    @work = Work.new
  end
  
  def create
    @work = Work.new(params[:work])
    
    respond_to do |format|
      if @work.save
        flash[:notice] = "仕事を登録しました．"
        format.html { redirect_to( :controller => "desktop_bookmark", :action => "index" ) }
        format.xml { render :xml => @work, :status => :created, :location => @work }
      else
        flash[:notice] = "仕事の登録に失敗しました．"
        format.html { render :action => "new" }
        format.xml { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @work = Work.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @work }
    end
  end
  
  def edit
    @work = Work.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml { render :xml => @work }
    end
  end

  def update
    @work = Work.find(params[:id])

    respond_to do |format|
      if @work.update_attributes(params[:task])
        flash[:notice] = "Update succeeded."
        format.html { redirect_to(:action => "show", :id => @work) }
        format.xml  { head :ok }
      else
        flash[:notice] = "Update failed."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @work = Work.find_by_id(params[:task_id])
    @work.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => "desktop_bookmark", :action => "index") }
      format.xml  { head :ok }
    end
  end

  def start
=begin
    if params[:task] != ""
      Task.current = Task.find_by_id(params[:task])
      $current_task = Task.current
      dirname = Time.now.strftime("%Y%m%d%H%M%S")
      dir = WindowsLibs.make_path(["app","assets","images","thumbnail",dirname])
      `mkdir #{dir}`
      Bookmark.create(:task => Task.current, :thumbnail => dirname)
      session[:task_id] = Task.current.id
      flash[:notice] = "#{Task.current.name} を開始しました．"
    else
      flash[:error] = "開始する作業を選択してください．"
    end
    redirect_to "/"
=end
  end
  
  def stop
=begin
    Bookmark.last.touch
    Task.current != nil ? flash[:notice] = "#{Task.current.name} を中断しました．" : nil
    session[:task_id] = nil
    Task.current = nil
    $current_task = nil
    redirect_to "/"
=end
  end
end
