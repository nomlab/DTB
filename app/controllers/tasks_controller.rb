# -*- coding: utf-8 -*-
require "./lib/windows"
class TasksController < ApplicationController
  def index
  end

  # 仕事および作業導入前のUIで，作業の一覧を表示
  def list
    @tasks = Task.all
  end
  
  def new
    @task = Task.new
  end
  
  def create
    @task = Task.new(params[:task])
    @task.work_id = params[:work_id]

    respond_to do |format|
      if @task.save
        flash[:notice] = "作業を登録しました．"
        format.html { redirect_to( :controller => "desktop_bookmark", :action => "index" ) }
        format.xml { render :xml => @task, :status => :created, :location => @task }
      else
        flash[:notice] = "作業の登録に失敗しました．"
        format.html { render :action => "new" }
        format.xml { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml { render :xml => @task }
    end
  end
  
  def edit
    @task = Task.find(params[:id])

    respond_to do |format|
      format.html # edit.html.erb
      format.xml { render :xml => @task }
    end
  end

  def update
    @task = Task.find(params[:id])

    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = "Update succeeded."
        format.html { redirect_to(:action => "show", :id => @task) }
        format.xml  { head :ok }
      else
        flash[:notice] = "Update failed."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @task.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def destroy
    @task = Task.find_by_id(params[:task_id])
    @task.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => "desktop_bookmark", :action => "index") }
      format.xml  { head :ok }
    end
  end

  def phoenix
    @task = Task.find(params[:id])
    
    files = @task.file_histories.uniq
    files.each do |file|
      # FileHistoryに参照用のメソッド用意すべき？
      WindowsLibs.restore_ap(file.path, false)
    end
    redirect_to :action => "show", :id => @task
  end

  def start_orig
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
  end

  def stop_orig
    Bookmark.last.touch
    Task.current != nil ? flash[:notice] = "#{Task.current.name} を中断しました．" : nil
    session[:task_id] = nil
    Task.current = nil
    $current_task = nil
    redirect_to "/"
  end
end
