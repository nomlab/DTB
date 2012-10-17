# -*- coding:utf-8 -*-
# script/runner 'eval(IO.readlines("collect_history.rb").join)'

require "uri"
require "./lib/windows"
require "./lib/referer_filter"

# 実行環境の指定　default:development
# 例： ruby make_history.rb -e production 
if ARGV[0] == "-e"
  Rails.env = ARGV[1]
end
require "./config/environment"

IMAGE_ROOT = WindowsLibs.make_path(["app","assets","images"])

def thumbnail_dir(bookmark)
  return WindowsLibs.make_path(["thumbnail", bookmark.start_time.strftime("%Y%m%d%H%M")])
end

# 計算機外部の履歴情報収集
def collect_web_history
  bookmark = Bookmark.last
  #  logfile = WindowsLibs.make_path(["lib","squid","var","logs","access.log"])
  logfile = WindowsLibs.make_path(["", "squid", "var", "logs", "access.log"])
  
  histories_old = []
  bookmark.web_histories.select(:path).each do |h|
    histories_old << h.path
  end
  count = histories_old.size
  
  histories = selection_data(referer_filter(logfile), 0.0)
  thumb_dir = thumbnail_dir(bookmark)
  
  (histories - histories_old).each do |h|

    thumbnail_file = WindowsLibs.make_path([thumb_dir, "thumbnail_#{count}"])
    thumbnail_path = WindowsLibs.make_path([IMAGE_ROOT, thumbnail_file])
    WindowsLibs.screen_capture(thumbnail_path, h)

    history = WebHistory.create(:path => h, :thumbnail => thumbnail_file)
    BookmarksWebHistories.create(:bookmark => bookmark, :web_history => history)
    count += 1
  end
end

# 計算機内部の履歴情報収集部
def collect_file_history(last_collect)
  histories_old = []
  bookmark = Bookmark.last
  bookmark.file_histories.each do |h|
    histories_old << h.path
  end
  
  histories = compare_file_access_log(last_collect)
  
  (histories - histories_old).each do |h|
    history = FileHistory.create(:path => h, :title => h.split("\\").last)
    BookmarksFileHistories.create(:bookmark => bookmark, :file_history => history)
  end
end

def compare_file_access_log(start_time)
  array = WindowsLibs.get_lnk(start_time)
  return array.uniq
end

##
# main

# ログファイルの設定(出力同期モードを真に)
#filename = WindowsLibs.make_path(["lib", "squid", "var", "logs", "access.log"])
filename = WindowsLibs.make_path(["","squid","var","logs","access.log"])
browselog = File.open(filename, "w")
browselog.sync = true

$t1 = Thread.new do 
  while true
    print "--- #{Time.now} ---\n"
    last_collect = Time.now
    sleep 60
    collect_web_history
    print "collect web_history successful\n"
    collect_file_history(last_collect)
    print "collect file_history successful\n"
  end
end

`#{WindowsLibs.make_path(["","squid","sbin","squid.exe"])}`
# `#{WindowsLibs.make_path(["lib","squid","sbin","squid.exe"])}`

# SIGINT を捕捉する。
Signal.trap('INT') do
  $t1.kill
  `taskkill /f /fi "imagename eq squid.exe"`
  browselog.close
end
