# -*- coding: utf-8 -*-
require "uri"
require "./lib/windows"
require "./lib/referer_filter"
require "./config/environment"

$current_bookmark = nil
$current_task     = nil
$current_work     = nil

ROOT = Rails.root.to_s.gsub(/\//, "\\")

THUMBNAIL_DIR = WindowsLibs.make_path([ROOT,"app","assets","images","thumbnail"])
PROXY_LOG = WindowsLibs.make_path(["","squid","var","logs","access.log"])
DEBUGFILE = "debug.txt"
ZERO = "0000"

def collect_web_history
  histories_old = $current_bookmark.web_histories.map{|wh| wh.path}
  count = histories_old.size
  
  histories = selection_data(referer_filter(PROXY_LOG, 0.0))
  print "there are #{(histories-histories_old).count} new histories\n"
  (histories - histories_old).each do |h|
    number = (ZERO+count.to_s)[-4..-1]
    thumbnail_path = WindowsLibs.make_path([THUMBNAIL_DIR, $current_bookmark.thumbnail, "thumbnail_#{number}"])
    WindowsLibs.screen_capture(thumbnail_path, h)
    
    history = WebHistory.create(:path => h)
    Timeline.create(:bookmark => $current_bookmark,
                    :history => history,
                    :thumbnail => number)
    
    count += 1
  end
end

def collect_file_history(last_collect)
  histories_old = $current_bookmark.filehistories.map{|fh| fh.path}
  histories = compare_file_access_log(last_collect)
  
  (histories - histories_old).each do |h|
    history = FileHistory.create(:path => h, :title => h.split("\\").last)
    Timeline.create(:bookmark => $current_bookmark, :history => history)
  end
end

def compare_file_access_log(start_time)
  array = WindowsLibs.get_lnk(start_time)
  return array.uniq
end

###
##  main
###

## ログファイルの設定(出力同期を真に)

browselog = File.open(PROXY_LOG, "w")
browselog.sync = true

$t1 = Thread.new do
  while true
    if $current_bookmark != nil
      print "--- #{Time.now} ---\n"
      last_collect = Time.now
      sleep 60

      collect_web_history
      print "collect web_history successfuly\n"
      collect_file_history(last_collect)
      print "collect file_history successfuly\n"
      $current_bookmark.commit
    else
      sleep 60
    end
  end
end

$t2 = Thread.new do
  `#{WindowsLibs.make_path(["","squid","sbin","squid.exe"])}`
end

at_exit do
  `taskkill /f /fi "imagename eq squid.exe"`
  $t1.kill
  $t2.kill
  browselog.close
end
