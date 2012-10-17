require "uri"
require "./lib/windows"
require "./lib/referer_filter"

$current_task = nil


THUMBNAIL_DIR = WindowsLibs.make_path(["app","assets","images","thumbnail"]) # "app\\assets\\images\\thumbnail"
LOG_FILE = WindowsLibs.make_path(["","squid","var","logs","access.log"])  # "\\squid\\var\\logs\\access.log"
ZERO = "0000"

def thumbnail_dir(bookmark)
  return WindowsLibs.make_path(["thumbnail", bookmark.start_time.strftime("%Y%m%d%H%M")]) # "thumbnail\\201204011200"
end


# 計算機外部の履歴収集
def collect_web_history
  bookmark = Bookmark.last
  
  histories_old = []
  bookmark.web_histories.select(:path).each do |wh|
    histories_old << wh.path
  end
  count = histories_old.size
  
  histories = selection_data(referer_filter(LOG_FILE, 0.0))
  
  (histories - histories_old).each do |h|
    number = (ZERO+count.to_s)[-4..-1]
    thumbnail_path = WindowsLibs.make_path([THUMBNAIL_DIR, bookmark.thumbnail, "thumbnail_#{number}"])
    WindowsLibs.screen_capture(thumbnail_path, h)
    
    history = WebHistory.create(:path => h)
    Timeline.create(:bookmark => bookmark, :history => history, :thumbnail => number)
    
    count += 1
  end
end

# 計算機内部の履歴収集
def collect_file_history(last_collect)
  histories_old = []
  bookmark = Bookmark.last
  bookmark.file_histories.select(:path).each do |fh|
    histories_old << fh.path
  end
  histories = compare_file_access_log(last_collect)
  
  (histories - histories_old).each do |h|
    history = FileHistory.create(:path => h, :title => h.split("\\").last)
    Timeline.create(:bookmark => bookmark, :history => history)
  end
end

def compare_file_access_log(start_time)
  array = WindowsLibs.get_lnk(start_time)
  return array.uniq
end

###
##  main
###

#ログファイルの設定(出力同期を真に)

browselog = File.open(LOG_FILE, "w")
browselog.sync = true

$t1 = Thread.new do
#  `#{WindowsLibs.make_path(["","squid","sbin","squid.exe"])}`
  while true
    if $current_task != nil
      print "--- #{Time.now} ---\n"
      last_collect = Time.now
      sleep 60
      #TimeLine.create(:start_time => last_collect, :end_time => Time.now)
      collect_web_history
      print "collect web_history successfuly\n"
      collect_file_history(last_collect)
      print "collect file_history successfuly\n"
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
