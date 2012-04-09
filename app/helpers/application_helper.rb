# -*- encoding: utf-8 -*-
module ApplicationHelper
  require_dependency 'lib/referer_filter'
  require 'time'
  require 'nkf'
  
  def jtime(time)
    if time
      time.strftime('%Y年%m月%d日(' + jweek(time) + ') %H時%M分')
    else
      ''
    end
  end
  
  def jdate(date)
    if date
      date.strftime('%Y年%m月%d日')
    else
      ''
    end
  end
  
  def jweek(date)
    %w(日 月 火 水 木 金 土)[date.wday]
  end
  
  def etime(time)
    time.strftime("%Y-%m-%d-%H")
  end 
  
  def image_show(title = nil)
    if title == nil
      image_tag('show.gif', :border => 0   )
    else
      image_tag('show.gif', :border => 0 ,:title=>  title  )
    end
  end
  
  def image_edit(title = nil)
    if title == nil
      image_tag('edit.gif', :border => 0   )
    else
      image_tag('edit.gif', :border => 0 ,:title=>  title  )
    end
  end
  
  def image_destroy(title = nil)
    if title == nil
      image_tag('destroy.gif', :border => 0   )
    else
      image_tag('destroy.gif', :border => 0 ,:title=>  title  )
    end
  end
  
  def image_next(title = nil)
    if title == nil
      image_tag('next.gif', :border => 0   )
    else
      image_tag('next.gif', :border => 0 ,:title=>  title  )
    end
  end
  
  def image_prev(title = nil)
    if title == nil
      image_tag('prev.gif', :border => 0   )
    else
      image_tag('prev.gif', :border => 0 ,:title=>  title  )
    end
  end
  
  def image_new(title = nil)
    if title == nil
      image_tag('new.gif', :border => 0   )
    else
      image_tag('new.gif', :border => 0 ,:title=>  title  )
    end
  end
  
  #################################################################
  # 参照したデータ一覧(計算機内部)を返すメソッド
  def getpath(bookmark)
    history_array = bookmark.file_histories

#    status = bookmark.repository_states
    status = [] if status == nil
    obj = ""

    history_array.each do |history|
      path = history.path
      
      ext = path.split(".").last
      icon = Exticon.find_by_ext(ext)
      if icon == nil
        `lib\\GetIcon.exe \"#{NKF.nkf("-s", path)}\" app\\assets\\images\\icons\\#{ext}.bmp`
        i = Exticon.new
        i.ext = ext
        i.save
      end
      obj << "<img src=\"/assets/icons/#{ext}.bmp\" alt=\"\" title=\"#{path}\" height=25 weight=25> "
      obj << path.split("\\").last
#      obj << "<a href = \"/file_history/" + "\"> <img src=\"/assets/open.png\" alt=\"\" title=\"現在の内容で開く\" height=20 weight=20>"
      obj << link_to(image_tag("open.png", :title => "現在の内容で開く", :size => "20x20"), :controller => "file_histories", :action => "link", :bookmark_id => bookmark.id, :id => history.id)
      #if history.flag
      #  obj << " ☆</a>" 
      #else
        obj << "</a>"
      #end

      status.each do |s|
        if path.downcase.include?(s.repo.path.downcase + "\\")
          obj << "<a href = \"/desktop_bookmark/restore/?path=" + path + "&repo=" + s.repo_id.to_s + "&num=" + s.revision.to_s + "\"> <img src=\"/assets/timemachine.png\" alt=\"\" title=\"保存当時の内容で開く\" height=25 weight=25> </a>"
        end
      end
      obj << "<br>\n"
    end

    obj + "<br>"
    obj.html_safe
  end 

  #################################################################
  # 参照したデータ一覧(計算機外部)とサムネイルをHTMLで返すメソッド
  def getpic(bookmark)
    history_array = bookmark.web_histories

    obj = ""
    history_array.each do |history|
      obj << make_html_to_url(history)
    end

    obj.html_safe
  end 

  def make_html_to_url(history)
    tag = '<a href = ' + history.path + "><img src=\"/assets/#{history.thumbnail}\.jpg\" alt=\"" + history.path + "\" height=200 width=250 title=\"" + history.path + "\"style=\"margin: 3px; border: 1px solid #606060;\" ><\/a>"

    tag.html_safe
  end 
  
  def get_repostate(bookmark)
    obj = ""
    rs = bookmark.repository_states
    rs.each do |r|
      obj << "リポジトリ：" + r.repo.path + "<br>\nリビジョン番号：" + r.revision.to_s + "<br><br>\n"
    end
    obj.html_safe
  end
end
