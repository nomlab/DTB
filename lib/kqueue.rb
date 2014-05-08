require 'rb-kqueue'
require 'sqlite3'

def main( argv )

  target = File.expand_path('~/DTBtest/sample')

  queue = KQueue::Queue.new
  queue.watch_file( target, :delete, :write, :extend, :attrib, :link, :rename, :revoke ) do |event|
    title = "sample"
    path = File.expand_path('~/DTBtest/sample')
    start_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    `osascript ./watch_frontmost.scpt`
    end_time = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    dtb_db = SQLite3::Database.new("/Users/okada/Dropbox/Nomlab/home/admin/misc/DTB/db/development.sqlite3")
    get_max_id_sql = "SELECT MAX(id) FROM unified_histories"
    id = dtb_db.execute(get_max_id_sql).flatten.first.to_i + 1
    insert_history = "INSERT INTO unified_histories VALUES(#{id}, '#{title}', '#{path}', 'file_history', '', '#{start_time}', '#{end_time}', '', datetime('now', 'localtime'), datetime('now', 'localtime'))"
    dtb_db.execute(insert_history)
    dtb_db.close
  end
  queue.run
end

main( ARGV )
