# -*- coding: utf-8 -*-
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
        format.html { redirect_to( :controller => "desktop_bookmark",
                                   :action => "index" ) }
        format.xml { render :xml => @work,
                            :status => :created,
                            :location => @work }
      else
        flash[:notice] = "仕事の登録に失敗しました．"
        format.html { render :action => "new" }
        format.xml { render :xml => @work.errors,
                            :status => :unprocessable_entity }
      end
    end
  end

  def show
    @work = Work.find_by_id(params[:id])
    @tasks = @work.tasks
    @selected_work = Work.current || @work
    @selected_tasks = @selected_work.tasks
    
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
      if @work.update_attributes(params[:work])
        flash[:notice] = "Update succeeded."
        format.html { redirect_to(:action => "show", :id => @work) }
        format.xml  { head :ok }
      else
        flash[:notice] = "Update failed."
        format.html { render :action => "edit" }
        format.xml  { render :xml => @work.errors,
                             :status => :unprocessable_entity }
      end
    end
  end

  def finish
    @work = Work.find(params[:work_id])
    @work.finish
    @depth = params[:depth].to_i
    respond_to do |format|
      if @work.finished?
        flash[:notice] = "successfuly finished."
      else
        flash[:error] = "failed to finish."
      end
      format.js
      format.html {render :controller => "desktop_bookmark", :action => "index"}
#      format.xml { head :ok }
    end
  end
  
  def destroy
    @work = Work.find_by_id(params[:work_id])
    @work.destroy

    respond_to do |format|
      format.html { redirect_to(:controller => "desktop_bookmark", :action => "index") }
      format.xml  { head :ok }
    end
  end

# methods for ajax
  def select
    @selected_work = Work.find_by_id(params[:work_id])
#    @selected_work = nil if params[:work_id] == ""
    @selected_tasks = @selected_work.tasks rescue []
    # ページ遷移しても選択状態を維持するために
    # セッションにid突っ込んだ．
    session[:work_id] = params[:work_id]
    session[:task_id] = params[:task_id]
    respond_to do |format|
      format.js
    end
  end


end
