require 'sqlite3'

def save_web_history_from_web_log(file)
  log_db = SQLite3::Database.new(file)
  get_last_log_sql = "SELECT * FROM log WHERE end_time = (SELECT MAX(end_time) FROM log)"
  last_log = log_db.execute(get_last_log_sql).flatten
  log_db.close
  dtb_db = SQLite3::Database.new("/Users/okada/Dropbox/Nomlab/home/admin/misc/DTB/db/development.sqlite3")
  get_max_id_sql = "SELECT MAX(id) FROM unified_histories"
  id = dtb_db.execute(get_max_id_sql).flatten.first.to_i + 1
  title = last_log[0]
  url = last_log[1]
  start_time = last_log[2]
  end_time = last_log[3]
  thumbnail = last_log[4]
  insert_history = "INSERT INTO unified_histories VALUES(#{id}, '#{title}', '#{url}', 'web_history', '', '#{start_time}', '#{end_time}', '#{thumbnail}', datetime('now', 'localtime'), datetime('now', 'localtime'))"
  dtb_db.execute(insert_history)
  dtb_db.close
end

guard :shell do
  watch(%r{^(mymindthetime.sqlite)$}) {|m| save_web_history_from_web_log("/Users/okada/Library/Application Support/Firefox/Profiles/wn9kf5tr.test/mymindthetime.sqlite") }
end

