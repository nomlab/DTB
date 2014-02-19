class FileLogDaemon < DaemonSpawn::Base
  def start(args)
    puts "trace file access start : #{Time.now}"
    `sudo #{Rails.root.to_s}/lib/track_emacs_file_log.d | awk -f #{Rails.root.to_s}/lib/file_log.awk > #{Rails.root.to_s}/log/file_access.log`
  end

  def stop
    puts "trace file access stop  : #{Time.now}"
  end
end

FileLogDaemon.spawn!({
                       :working_dir => Rails.root,
                       :log_file => File.expand_path(File.dirname(__FILE__) + '/../log/file_log_daemon.log'),
                       :pid_file => File.expand_path(File.dirname(__FILE__) + '/../tmp/pids/file_log_daemon.pid'),
                       :sync_log => true,
                       :singleton => true
                })
